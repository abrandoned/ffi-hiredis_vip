module FFI
  module HiredisVip
    class Touch
      def initialize(client)
        @client = client
      end

      def touch(*keys)
        reply = nil
        keys = keys.flatten
        number_of_touches = keys.size
        command = "TOUCH#{' %b' * number_of_touches}"
        command_args = []
        keys.each do |key|
          command_args << :pointer << key << :size_t << key.size
        end

        synchronize do |connection|
          reply = @client.execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_INTEGER
          reply[:integer]
        else
          0
        end
      end

      def supports_touch?
        true
      end

    end # class Touch
  end # module HiredisVip
end # module FFI
