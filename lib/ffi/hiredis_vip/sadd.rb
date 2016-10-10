module FFI
  module HiredisVip
    class Sadd
      def initialize(client)
        @client = client
      end

      def sadd(key, *values)
        values = values.flatten
        value_size_pairs = []
        number_of_values = values.size
        values.each do |value|
          value_size_pairs << :string << value << :size_t << value.size
        end

        @client.synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "SADD %b#{' %b' * number_of_values}", :string, key, :size_t, key.size, *value_size_pairs)

          case reply[:type] 
          when :REDIS_REPLY_INTEGER
            reply[:integer]
          else
            0
          end
        end
      end
    end # class Sadd
  end # module HiredisVip
end # module FFI
