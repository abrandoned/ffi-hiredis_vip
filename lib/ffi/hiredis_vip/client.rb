require 'ffi/hiredis_vip'
require 'ffi/hiredis_vip/info'
require 'ffi/hiredis_vip/exists'
require 'ffi/hiredis_vip/exists3'
require 'ffi/hiredis_vip/sadd'
require 'ffi/hiredis_vip/sadd_before_2_4'
require 'ffi/hiredis_vip/scan'
require 'ffi/hiredis_vip/scan_before_2_8'
require 'ffi/hiredis_vip/sscan'
require 'ffi/hiredis_vip/sscan_before_2_8'
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
        set_sadd_provider # Changed in Redis2.4
        set_scan_provider # Introduced in Redis2.8
        set_sscan_provider # Introduced in Redis2.8
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

      def expire(key, seconds)
        reply = nil
        time_in_seconds = "#{seconds}"
        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "EXPIRE %b %b", :string, key, :size_t, key.size, :string, time_in_seconds, :size_t, time_in_seconds.size)
        end

        return !reply.nil? && !reply.null? && reply[:type] == :REDIS_REPLY_INTEGER && reply[:integer] == 1
      end

      def flushall
        reply = nil
        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "FLUSHALL")
        end

        return !reply.nil? && !reply.null? && reply[:type] == :REDIS_REPLY_STRING && reply[:str] == OK
      end

      def flushdb
        reply = nil
        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "FLUSHDB")
        end

        return !reply.nil? && !reply.null? && reply[:type] == :REDIS_REPLY_STRING && reply[:str] == OK
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

      def sadd(key, *values)
        @sadd_provider.sadd(key, *values)
      end

      def scan(cursor, options = {})
        @scan_provider.scan(cursor, options)
      end

      def scan_each(options = {}, &block)
        return to_enum(:scan_each, options) unless block_given?

        cursor = "0"
        loop do
          cursor, keys = scan(cursor, options)
          keys.each(&block)
          break if cursor == "0"
        end
      end

      def sscan(key, cursor, options = {})
        @sscan_provider.sscan(key, cursor, options)
      end

      def sscan_each(key, options = {}, &block)
        return to_enum(:sscan_each, key, options) unless block_given?

        cursor = "0"
        loop do
          cursor, values = sscan(key, cursor, options)
          values.each(&block)
          break if cursor == "0"
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
        reply = nil
        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "TTL %b", :string, key, :size_t, key.size)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type] 
        when :REDIS_REPLY_INTEGER
          reply[:integer]
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

      def redis_version_greater_than_2_4?
        redis_info_parsed["redis_version"] && ::Gem::Version.new(redis_info_parsed["redis_version"]) >= ::Gem::Version.new("2.4.0")
      end

      def redis_version_greater_than_2_8?
        redis_info_parsed["redis_version"] && ::Gem::Version.new(redis_info_parsed["redis_version"]) >= ::Gem::Version.new("2.8.0")
      end

      def set_exists_provider
        @exists_provider = case
                           when redis_version_3?
                             ::FFI::HiredisVip::Exists3.new(self)
                           else
                             ::FFI::HiredisVip::Exists.new(self)
                           end
      end

      def set_sadd_provider
        @sadd_provider = case
                         when redis_version_greater_than_2_4?
                           ::FFI::HiredisVip::Sadd.new(self)
                         else
                           ::FFI::HiredisVip::SaddBefore24.new(self)
                         end
      end

      def set_scan_provider
        @scan_provider = case
                         when redis_version_greater_than_2_8?
                           ::FFI::HiredisVip::Scan.new(self)
                         else
                           ::FFI::HiredisVip::ScanBefore28.new(self)
                         end
      end

      def set_sscan_provider
        @sscan_provider = case
                         when redis_version_greater_than_2_8?
                           ::FFI::HiredisVip::Sscan.new(self)
                         else
                           ::FFI::HiredisVip::SscanBefore28.new(self)
                         end
      end
    end # class Client
  end # module HiredisVip
end # module FFI
