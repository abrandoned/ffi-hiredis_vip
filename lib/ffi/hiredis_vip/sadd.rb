module FFI
  module HiredisVip
    class Sadd
      def initialize(client)
        @client = client
      end

      def sadd(key, *values)
        reply = nil
        values = values.flatten
        number_of_values = values.size
        command = "SADD %b#{' %b' * number_of_values}"
        command_args = [ :string, key, :size_t, key.size ]
        values.each do |value|
          command_args << :string << value << :size_t << value.size
        end

        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type] 
        when :REDIS_REPLY_INTEGER
          reply[:integer]
        else
          0
        end
      end

      private

      def synchronize
        @client.synchronize do |connection|
          yield(connection)
        end
      end

    end # class Sadd
  end # module HiredisVip
end # module FFI
