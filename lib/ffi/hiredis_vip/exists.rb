module FFI
  module HiredisVip
    class Exists
      def initialize(client)
        @client = client
      end

      def exists(*keys)
        reply = nil
        keys = keys.flatten
        number_of_exists = keys.size
        command = "EXISTS#{' %b' * number_of_exists}"
        command_args = []
        keys.each do |key|
          command_args << :string << key << :size_t << key.size
        end

        @client.synchronize do |connection|
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
    end # class Exists
  end # module HiredisVip
end # module FFI
