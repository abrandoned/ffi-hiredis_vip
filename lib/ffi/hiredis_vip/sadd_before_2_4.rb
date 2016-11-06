module FFI
  module HiredisVip
    class SaddBefore24
      def initialize(client)
        @client = client
      end

      def sadd(key, *values)
        values = values.flatten
        number_added_to_set = 0
        command = "SADD %b %b"

        values.each do |value|
          begin
            reply = nil
            value = value.to_s
            command_args = [ :pointer, key, :size_t, key.size, :pointer, value, :size_t, value.size ]
            synchronize do |connection|
              reply = @client.execute_command(connection, command, *command_args)

              next if reply.nil? || reply.null?

              case reply[:type] 
              when :REDIS_REPLY_INTEGER
                number_added_to_set = number_added_to_set + reply[:integer]
              end
            end
          ensure
            ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
          end
        end

        number_added_to_set
      end

      private

      def synchronize
        @client.synchronize do |connection|
          yield(connection)
        end
      end

    end # class SaddBefore24
  end # module HiredisVip
end # module FFI
