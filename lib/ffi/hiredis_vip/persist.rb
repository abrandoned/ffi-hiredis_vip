module FFI
  module HiredisVip
    class Persist
      def initialize(client)
        @client = client
      end

      def persist(key)
        reply = nil
        command = "PERSIST %b"
        command_args = [ :pointer, key, :size_t, key.size ]
        synchronize do |connection|
          reply = @client.execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_INTEGER
          reply[:integer]
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def supports_persist?
        true
      end

      private

      def synchronize
        @client.synchronize do |connection|
          yield(connection)
        end
      end
    end # class Persist
  end # module HiredisVip
end # module FFI
