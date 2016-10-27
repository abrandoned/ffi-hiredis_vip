module FFI
  module HiredisVip
    class TouchBefore321
      def initialize(client)
        @client = client
      end

      def touch(*keys)
        raise <<-TOUCH_ERROR
          TOUCH Command in Redis is only available on Servers >= 3.2.1
          The Redis Server you are connecting to is using a version that is not supported.

          == > INFO
            #{@client.info}
        TOUCH_ERROR
      end

      def supports_touch?
        false
      end

    end # class TouchBefore321
  end # module HiredisVip
end # module FFI
