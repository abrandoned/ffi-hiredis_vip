module FFI
  module HiredisVip
    class Exists
      def initialize(client)
        @client = client
      end

      def exists(*keys)
        keys = keys.flatten
        number_of_exists = 0

        keys.each do |key|
          @client.synchronize do |connection|
            reply = ::FFI::HiredisVip::Core.command(connection, "EXISTS %b", :string, key, :size_t, key.size)

            case reply[:type] 
            when :REDIS_REPLY_INTEGER
              number_of_exists = number_of_exists + reply[:integer]
            end
          end
        end

        number_of_exists
      end
    end # class Exists
  end # module HiredisVip
end # module FFI
