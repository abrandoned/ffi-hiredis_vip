require 'ffi/hiredis_vip'
require 'ffi/hiredis_vip/info'
require 'ffi/hiredis_vip/exists'
require 'ffi/hiredis_vip/exists3'
require 'monitor'

module FFI
  module HiredisVip
    class Client
      include MonitorMixin

      OK = "OK"
      PONG = "PONG"

      def initialize(address, port)
        @connection = ::FFI::HiredisVip::Core.connect(address, port)

        super() # MonitorMixin#initialize

        set_exists_provider # Changed in Redis3
      end

      def synchronize
        mon_synchronize { yield(@connection) }
      end

      def del(*keys)
        keys = keys.flatten
        key_size_pairs = []
        number_of_deletes = keys.size
        keys.each do |key|
          key_size_pairs << :string << key << :size_t << key.size
        end

        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "DEL#{' %b' * number_of_deletes}", *key_size_pairs)

          case reply[:type] 
          when :REDIS_REPLY_INTEGER
            reply[:integer]
          else
            0
          end
        end
      end

      def dump(key)
        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "DUMP %b", :string, key, :size_t, key.size)

          case reply[:type] 
          when :REDIS_REPLY_STRING
            reply[:str]
          else
            nil
          end
        end
      end

      def echo(value)
        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "ECHO %b", :string, value, :size_t, value.size)

          case reply[:type] 
          when :REDIS_REPLY_STRING
            reply[:str]
          else
            nil
          end
        end
      end

      def exists(*keys)
        @exists_provider.exists(*keys)
      end

      def exists?(key)
        exists(key) == 1
      end

      def get(key)
        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "GET %b", :string, key, :size_t, key.size)

          case reply[:type] 
          when :REDIS_REPLY_STRING
            reply[:str]
          else
            nil
          end
        end
      end
      alias_method :[], :get

      def info
        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "INFO")

          case reply[:type] 
          when :REDIS_REPLY_STRING
            reply[:str]
          else
            ""
          end
        end
      end

      def ping
        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "PING")

          case reply[:type] 
          when :REDIS_REPLY_STATUS
            reply[:str] == PONG
          else
            false
          end
        end
      end

      def set(key, value)
        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "SET %b %b", :string, key, :size_t, key.size, :string, value, :size_t, value.size)

          case reply[:type] 
          when :REDIS_REPLY_STATUS
            reply[:str] == OK
          else
            false
          end
        end
      end
      alias_method :[]=, :set

      def ttl(key)
        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "TTL %b", :string, key, :size_t, key.size)

          case reply[:type] 
          when :REDIS_REPLY_INTEGER
            reply[:integer]
          else
            0
          end
        end
      end

      private

      def redis_info_parsed
        @redis_info_parsed ||= ::FFI::HiredisVip::Info.new(info)
      end

      def redis_version_2?
        redis_info_parsed["redis_version"] && redis_info_parsed["redis_version"].start_with?("2")
      end

      def redis_version_3?
        redis_info_parsed["redis_version"] && redis_info_parsed["redis_version"].start_with?("3")
      end

      def set_exists_provider
        @exists_provider = case
                           when redis_version_3?
                             ::FFI::HiredisVip::Exists3.new(self)
                           else
                             ::FFI::HiredisVip::Exists.new(self)
                           end
      end
    end # class Client
  end # module HiredisVip
end # module FFI
