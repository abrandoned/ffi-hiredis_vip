module FFI
  module HiredisVip
    class SscanBefore28
      def initialize(client)
        @client = client
      end

      def sscan(key, cursor, options = {})
        raise <<-SCAN_ERROR
          SCAN Command in Redis is only available on Servers >= 2.8.0
          The Redis Server you are connecting to is using a version that is not supported.

          == > INFO
            #{@client.info}
        SCAN_ERROR
      end
    end # class SscanBefore28
  end # module HiredisVip
end # module FFI
