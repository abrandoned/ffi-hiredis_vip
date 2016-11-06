require "lib/hiredis_vip/client"

module FFI
  module HiredisVip
    class ClusterClient < ::FFI::HiredisVip::Client
      def initialize(options = {})
        super
      end

      def execute_command(*args)
        ::FFI::HiredisVip::Core.cluster_command(*args)
      end

    private
      def set_connection(options = {})
        host = options[:host] || "localhost"
        port = (options[:port] || 6379).to_i

        @connection = ::FFI::HiredisVip::Core.connect(host, port)
      end

      def set_database(options = {})
        database = options[:db]
        raise "Cannot select database specified" if database && !select?(database)
      end
    end
  end
end
