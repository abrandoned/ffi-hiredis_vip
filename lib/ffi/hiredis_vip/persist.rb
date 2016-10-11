module FFI
  module HiredisVip
    class Persist
      def initialize(client)
        @client = client
      end

      def persist(key)
        reply = nil
        @client.synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "PERSIST %b", :string, key, :size_t, key.size)
        end

        return nil if reply.nil?

        case reply[:type]
        when :REDIS_REPLY_INTEGER
          reply[:integer]
        end
      end
    end # class Persist
  end # module HiredisVip
end # module FFI
