module FFI
  module HiredisVip
    class SaddBefore24
      def initialize(client)
        @client = client
      end

      def sadd(key, *values)
        values = values.flatten
        number_added_to_set = 0

        values.each do |value|
          @client.synchronize do |connection|
            reply = ::FFI::HiredisVip::Core.command(connection, "SADD %b %b", :string, key, :size_t, key.size, :string, value, :size_t, value.size)

            case reply[:type] 
            when :REDIS_REPLY_INTEGER
              number_added_to_set = number_added_to_set + reply[:integer]
            end
          end
        end

        number_added_to_set
      end
    end # class SaddBefore24
  end # module HiredisVip
end # module FFI
