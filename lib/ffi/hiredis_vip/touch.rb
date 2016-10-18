module FFI
  module HiredisVip
    class Touch
      def initialize(client)
        @client = client
      end

      def touch(*keys)
        reply = nil
        keys = keys.flatten
        key_size_pairs = []
        number_of_touches = keys.size
        keys.each do |key|
          key_size_pairs << :string << key << :size_t << key.size
        end

        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "TOUCH#{' %b' * number_of_touches}", *key_size_pairs)
        end

        case reply[:type]
        when :REDIS_REPLY_INTEGER
          reply[:integer]
        else
          0
        end
      end
    end # class Touch
  end # module HiredisVip
end # module FFI
