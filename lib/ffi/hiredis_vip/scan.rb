module FFI
  module HiredisVip
    class Scan
      def initialize(client)
        @client = client
      end

      def scan(cursor, options = {})
        reply = nil
        command = "SCAN %b"
        command_args = [ :string, cursor, :size_t, cursor.size ]

        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, command, *command_args)
        end

        return nil if reply.nil?

        # TODO: more error checking here?
        case reply[:type]
        when :REDIS_REPLY_ARRAY
          [ scan_results_cursor(reply), scan_results_to_array(reply) ]
        end
      end

      def supports_scan?
        true
      end

      private

      def scan_results_cursor(reply)
        zeroth_result = ::FFI::HiredisVip::Core.redisReplyElement(reply, 0)

        if !zeroth_result.null? && zeroth_result[:type] == :REDIS_REPLY_STRING
          zeroth_result[:str]
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
            scan_results << result[:str] if result[:type] == :REDIS_REPLY_STRING
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

    end # class Scan
  end # module HiredisVip
end # module FFI
