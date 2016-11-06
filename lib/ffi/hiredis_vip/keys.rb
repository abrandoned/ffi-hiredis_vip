module FFI
  module HiredisVip
    class Keys
      def initialize(client)
        @client = client
      end

      def keys(pattern)
        reply = nil
        pattern = "#{pattern}"
        command = "KEYS %b"
        command_args = [ :pointer, pattern, :size_t, pattern.size ]

        synchronize do |connection|
          reply = @client.execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        # TODO: more error checking here? what is correct response on nothing?
        case reply[:type]
        when :REDIS_REPLY_ARRAY
          keys_results_to_array(reply)
        else
          []
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      private

      def keys_results_to_array(array_reply)
        keys_results = []

        0.upto(array_reply[:elements] - 1) do |element_number|
          result = ::FFI::HiredisVip::Core.redisReplyElement(array_reply, element_number)

          case result[:type]
          when :REDIS_REPLY_STRING
            keys_results << result[:str].dup
          end
        end

        keys_results
      end

      def synchronize
        @client.synchronize do |connection|
          yield(connection)
        end
      end

    end # class Keys
  end # module HiredisVip
end # module FFI
