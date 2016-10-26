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
          command_args = [ :string, key, :size_t, key.size, :string, value, :size_t, value.size ]
          synchronize do |connection|
            reply = ::FFI::HiredisVip::Core.command(connection, command, *command_args)

            next if reply.nil? || reply.null?

            case reply[:type] 
            when :REDIS_REPLY_INTEGER
              number_added_to_set = number_added_to_set + reply[:integer]
            end
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
