module FFI
  module HiredisVip
    class Exists3
      def initialize(client)
        @client = client
      end

      def exists(*keys)
        keys = keys.flatten
        key_size_pairs = []
        number_of_exists = keys.size
        keys.each do |key|
          key_size_pairs << :string << key << :size_t << key.size
        end

        @client.synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "EXISTS#{' %b' * number_of_exists}", *key_size_pairs)

          case reply[:type] 
          when :REDIS_REPLY_INTEGER
            reply[:integer]
          else
            0
          end
        end
      end
    end # class Exists3
  end # module HiredisVip
end # module FFI
