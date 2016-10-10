module FFI
  module HiredisVip
    class ScanBefore28
      def initialize(client)
        @client = client
      end

      def scan(cursor, options = {})
        raise <<-SCAN_ERROR
          SCAN Command in Redis is only available on Servers >= 2.8.0
          The Redis Server you are connecting to is using a version that is not supported.

          == > INFO
            #{@client.info}
        SCAN_ERROR
      end
    end # class ScanBefore28
  end # module HiredisVip
end # module FFI
