module FFI
  module HiredisVip
    class Mget
      def initialize(client)
        @client = client
      end

      def mget(*keys)
        reply = nil
        keys = keys.flatten
        command = "MGET"
        command_args = []
        keys.each do |key|
          command << " %b"
          command_args << :string << key << :size_t << key.size
        end

        synchronize do |connection|
          reply = @client.execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        # TODO: more error checking here? what is correct response on nothing?
        case reply[:type]
        when :REDIS_REPLY_ARRAY
          mget_results_to_array(reply)
        else
          []
        end
      end

      private

      def mget_results_to_array(array_reply)
        mget_results = []

        0.upto(array_reply[:elements] - 1) do |element_number|
          result = ::FFI::HiredisVip::Core.redisReplyElement(array_reply, element_number)

          case result[:type]
          when :REDIS_REPLY_STRING
            mget_results << result[:str]
          when :REDIS_REPLY_NIL
            mget_results << nil
          end
        end

        mget_results
      end

      def synchronize
        @client.synchronize do |connection|
          yield(connection)
        end
      end

    end # class Mget
  end # module HiredisVip
end # module FFI
