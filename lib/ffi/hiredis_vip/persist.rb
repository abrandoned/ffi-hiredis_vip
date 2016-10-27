module FFI
  module HiredisVip
    class Persist
      def initialize(client)
        @client = client
      end

      def persist(key)
        reply = nil
        command = "PERSIST %b"
        command_args = [ :string, key, :size_t, key.size ]
        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_INTEGER
          reply[:integer]
        end
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
