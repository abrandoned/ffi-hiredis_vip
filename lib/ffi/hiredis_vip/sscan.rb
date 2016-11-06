module FFI
  module HiredisVip
    class Sscan
      def initialize(client)
        @client = client
      end

      def sscan(key, cursor, options = {})
        reply = nil
        command = "SSCAN %b %b"
        command_args = [ :pointer, key, :size_t, key.size, :string, cursor, :size_t, cursor.size ]

        if options[:match]
          matcher = "#{options[:match]}"
          command << " MATCH %b"
          command_args << :pointer << matcher << :size_t << matcher.size
        end

        if options[:count]
          count = "#{options[:count]}"
          command << " COUNT %b"
          command_args << :pointer << count << :size_t << count.size
        end

        synchronize do |connection|
          reply = @client.execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        # TODO: more error checking here?
        case reply[:type]
        when :REDIS_REPLY_ARRAY
          [ scan_results_cursor(reply), scan_results_to_array(reply) ]
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def supports_sscan?
        true
      end

      private

      def scan_results_cursor(reply)
        zeroth_result = ::FFI::HiredisVip::Core.redisReplyElement(reply, 0)

        if !zeroth_result.null? && zeroth_result[:type] == :REDIS_REPLY_STRING
          zeroth_result[:str].dup
        else
          raise "probs" # TODO: what do we do here
        end
      end

      def scan_results_to_array(reply)
        scan_results = []
        array_reply = ::FFI::HiredisVip::Core.redisReplyElement(reply, 1)

        if !array_reply.null? && array_reply[:type] == :REDIS_REPLY_ARRAY
          0.upto(array_reply[:elements] - 1) do |element_number|
            result = ::FFI::HiredisVip::Core.redisReplyElement(array_reply, element_number)
            scan_results << result[:str].dup if result[:type] == :REDIS_REPLY_STRING
          end

          scan_results
        else
          raise "probs" # TODO: what do we do here
        end
      end

      def synchronize
        @client.synchronize do |connection|
          yield(connection)
        end
      end

    end # class Sscan
  end # module HiredisVip
end # module FFI
