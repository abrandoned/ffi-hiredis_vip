module FFI
  module HiredisVip
    class ExistsBefore3
      def initialize(client)
        @client = client
      end

      def exists(*keys)
        keys = keys.flatten
        number_of_exists = 0
        command = "EXISTS %b"

        keys.each do |key|
          begin
            reply = nil
            command_args = [ :pointer, key, :size_t, key.size ]
            @client.synchronize do |connection|
              reply = @client.execute_command(connection, command, *command_args)
            end

            next if reply.nil? || reply.null?

            case reply[:type] 
            when :REDIS_REPLY_INTEGER
              number_of_exists = number_of_exists + reply[:integer]
            end
          ensure
            ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
          end
        end

        number_of_exists
      end
    end # class ExistsBefore3
  end # module HiredisVip
end # module FFI
