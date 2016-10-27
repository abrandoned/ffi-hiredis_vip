module FFI
  module HiredisVip
    class PersistBefore22
      def initialize(client)
        @client = client
      end

      def persist(key)
        raise <<-SCAN_ERROR
          PERSIST Command in Redis is only available on Servers >= 2.2.0
          The Redis Server you are connecting to is using a version that is not supported.

          == > INFO
            #{@client.info}
        SCAN_ERROR
      end

      def supports_persist?
        false
      end
    end # class PersistBefore22
  end # module HiredisVip
end # module FFI
