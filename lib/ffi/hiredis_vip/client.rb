require 'ffi/hiredis_vip'
require 'ffi/hiredis_vip/info'
require 'ffi/hiredis_vip/exists'
require 'ffi/hiredis_vip/exists_before_3'
require 'ffi/hiredis_vip/keys'
require 'ffi/hiredis_vip/mget'
require 'ffi/hiredis_vip/persist'
require 'ffi/hiredis_vip/persist_before_2_2'
require 'ffi/hiredis_vip/sadd'
require 'ffi/hiredis_vip/sadd_before_2_4'
require 'ffi/hiredis_vip/scan'
require 'ffi/hiredis_vip/scan_before_2_8'
require 'ffi/hiredis_vip/set'
require 'ffi/hiredis_vip/set_before_2_6_12'
require 'ffi/hiredis_vip/sscan'
require 'ffi/hiredis_vip/sscan_before_2_8'
require 'ffi/hiredis_vip/touch'
require 'ffi/hiredis_vip/touch_before_3_2_1'
require 'monitor'

module FFI
  module HiredisVip
    class Client
      include MonitorMixin

      OK = "OK"
      PONG = "PONG"

      def initialize(options = {})
        super() # MonitorMixin#initialize

        set_connection(options)
        set_database(options)

        set_exists_provider # Changed in Redis3
        set_persist_provider # Added in Redis2.2
        set_sadd_provider # Changed in Redis2.4
        set_scan_provider # Introduced in Redis2.8
        set_set_provider # Changed in 2.6.12
        set_sscan_provider # Introduced in Redis2.8
        set_touch_provider # Introduced in Redis3.2.1
      end

      def synchronize
        mon_synchronize { yield(@connection) }
      end

      def execute_command(*args)
        ::FFI::HiredisVip::Core.command(*args)
      end

      def dbsize
        reply = nil
        synchronize do |connection|
          reply = execute_command(connection, "DBSIZE")
        end

        case reply[:type]
        when :REDIS_REPLY_INTEGER
          reply[:integer]
        else
          0
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def decr(key)
        reply = nil
        command = "DECR %b"
        command_args = [ :pointer, key, :size_t, key.size ]
        synchronize do |connection|
          reply = execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_INTEGER
          reply[:integer]
        else
          0
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def decrby(key, amount)
        reply = nil
        _amount = "#{amount}"
        command = "DECRBY %b %b"
        command_args = [ :pointer, key, :size_t, key.size, :string, _amount, :size_t, _amount.size ]
        synchronize do |connection|
          reply = execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_INTEGER
          reply[:integer]
        else
          0
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def del(*keys)
        reply = nil
        keys = keys.flatten
        number_of_deletes = keys.size
        command = "DEL#{' %b' * number_of_deletes}"
        command_args = []
        keys.each do |key|
          command_args << :pointer << key << :size_t << key.size
        end

        synchronize do |connection|
          reply = execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_INTEGER
          reply[:integer]
        else
          0
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def dump(key)
        reply = nil
        command = "DUMP %b"
        command_args = [ :pointer, key, :size_t, key.size ]
        synchronize do |connection|
          reply = execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_STRING
          reply[:str].dup
        else
          nil
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def echo(value)
        reply = nil
        command = "ECHO %b"
        command_args = [ :pointer, value, :size_t, value.size ]
        synchronize do |connection|
          reply = execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_STRING
          reply[:str].dup
        when :REDIS_REPLY_NIL
          nil
        else
          nil
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def echo?(value)
        echo(value) == value
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
        command = "EXPIRE %b %b"
        command_args = [ :pointer, key, :size_t, key.size, :string, time_in_seconds, :size_t, time_in_seconds.size ]
        synchronize do |connection|
          reply = execute_command(connection, command, *command_args)
        end

        # TODO: should we return a 0 here?
        return 0 if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_INTEGER
          reply[:integer]
        else
          0
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def expire?(key, seconds)
        expire(key, seconds) == 1
      end

      def expireat(key, unix_time)
        reply = nil
        epoch = "#{unix_time}"
        command = "EXPIREAT %b %b"
        command_args = [ :pointer, key, :size_t, key.size, :string, epoch, :size_t, epoch.size ]
        synchronize do |connection|
          reply = execute_command(connection, command, *command_args)
        end

        return 0 if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_INTEGER
          reply[:integer]
        else
          0
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def expireat?(key, unix_time)
        expireat(key, unix_time) == 1
      end

      def flushall
        reply = nil
        synchronize do |connection|
          reply = execute_command(connection, "FLUSHALL")
        end

        return "" if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_STRING
          reply[:str].dup
        else
          ""
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def flushall?
        flushall == OK
      end

      def flushdb
        reply = nil
        synchronize do |connection|
          reply = execute_command(connection, "FLUSHDB")
        end

        return "" if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_STRING
          reply[:str].dup
        else
          ""
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def flushdb?
        flushdb == OK
      end

      def get(key)
        reply = nil
        command = "GET %b"
        command_args = [ :pointer, key, :size_t, key.size ]

        synchronize do |connection|
          reply = execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_STRING
          reply[:str].dup
        when :REDIS_REPLY_NIL
          nil
        else
          nil # TODO: should this be empty string?
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end
      alias_method :[], :get

      def incr(key)
        reply = nil
        command = "INCR %b"
        command_args = [ :pointer, key, :size_t, key.size ]
        synchronize do |connection|
          reply = execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_INTEGER
          reply[:integer]
        else
          0
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def incrby(key, amount)
        reply = nil
        _amount = "#{amount}"
        command = "INCRBY %b %b"
        command_args = [ :pointer, key, :size_t, key.size, :string, _amount, :size_t, _amount.size ]
        synchronize do |connection|
          reply = execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_INTEGER
          reply[:integer]
        else
          0
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def info
        reply = nil
        synchronize do |connection|
          reply = execute_command(connection, "INFO")
        end

        return "" if reply.nil? || reply.null?

        case reply[:type] 
        when :REDIS_REPLY_STRING
          reply[:str].dup
        else
          ""
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def keys(pattern)
        @keys_provider ||= ::FFI::HiredisVip::Keys.new(self)
        @keys_provider.keys(pattern)
      end

      def mget(*keys)
        @mget_provider ||= ::FFI::HiredisVip::Mget.new(self)
        @mget_provider.mget(*keys)
      end

      def persist(key)
        @persist_provider.persist(key)
      end

      def persist?(key)
        persist(key) == 1 || ttl(key) == -1
      end

      def ping
        reply = nil
        synchronize do |connection|
          reply = execute_command(connection, "PING")
        end

        return nil if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_STATUS
          reply[:str].dup
        when :REDIS_REPLY_STRING
          reply[:str].dup
        else
          ""
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def ping?
        ping == PONG
      end

      def psetex(key, value, expiry)
        @set_provider.psetex(key, value, expiry)
      end

      def reconnect
        reply = nil
        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.redisReconnect(connection)
        end

        case reply
        when :REDIS_OK
          true
        else
          false
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
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

      def select(db)
        reply = nil
        db = "#{db}"
        command = "SELECT %b"
        command_args = [ :string, db, :size_t, db.size ]
        synchronize do |connection|
          reply = execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type]
        when :REDIS_REPLY_STATUS
          reply[:str].dup
        else
          nil
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def select?(db)
        select(db) == OK
      end

      def set(key, value, options = {})
        @set_provider.set(key, value, options)
      end
      alias_method :[]=, :set

      def set?(key, value, options = {})
        set(key, value, options) == OK
      end

      def setex(key, value, expiry)
        @set_provider.setex(key, value, expiry)
      end

      def setnx(key, value)
        @set_provider.setnx(key, value)
      end

      def supports_persist?
        @persist_provider.supports_persist?
      end

      def supports_scan?
        @scan_provider.supports_scan?
      end

      def supports_scan_each?
        @scan_provider.supports_scan?
      end

      def supports_sscan?
        @sscan_provider.supports_sscan?
      end

      def supports_sscan_each?
        @sscan_provider.supports_sscan?
      end

      def supports_touch?
        @touch_provider.supports_touch?
      end

      def ttl(key)
        reply = nil
        command = "TTL %b"
        command_args = [ :pointer, key, :size_t, key.size ]
        synchronize do |connection|
          reply = execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type] 
        when :REDIS_REPLY_INTEGER
          reply[:integer]
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def touch(*keys)
        @touch_provider.touch(*keys)
      end

      private

      def redis_info_parsed
        @redis_info_parsed ||= ::FFI::HiredisVip::Info.new(info)
      end

      def redis_version_2?
        return @redis_version_2 unless @redis_version_2.nil?

        @redis_version_2 = redis_info_parsed["redis_version"] &&
                           redis_info_parsed["redis_version"].start_with?("2")
      end

      def redis_version_3?
        return @redis_version_3 unless @redis_version_3.nil?

        @redis_version_3 = redis_info_parsed["redis_version"] &&
                           redis_info_parsed["redis_version"].start_with?("3")
      end

      def redis_version_greater_than_2_2?
        return @redis_version_greater_than_2_2 unless @redis_version_greater_than_2_2.nil?

        @redis_version_greater_than_2_2 = redis_info_parsed["redis_version"] &&
                                          ::Gem::Version.new(redis_info_parsed["redis_version"]) >= ::Gem::Version.new("2.2.0")
      end

      def redis_version_greater_than_2_4?
        return @redis_version_greater_than_2_4 unless @redis_version_greater_than_2_4.nil?

        @redis_version_greater_than_2_4 = redis_info_parsed["redis_version"] &&
                                          ::Gem::Version.new(redis_info_parsed["redis_version"]) >= ::Gem::Version.new("2.4.0")
      end

      def redis_version_greater_than_2_6_12?
        return @redis_version_greater_than_2_6_12 unless @redis_version_greater_than_2_6_12.nil?

        @redis_version_greater_than_2_6_12 = redis_info_parsed["redis_version"] &&
                                             ::Gem::Version.new(redis_info_parsed["redis_version"]) >= ::Gem::Version.new("2.6.12")
      end

      def redis_version_greater_than_2_8?
        return @redis_version_greater_than_2_8 unless @redis_version_greater_than_2_8.nil?

        @redis_version_greater_than_2_8 = redis_info_parsed["redis_version"] &&
                                          ::Gem::Version.new(redis_info_parsed["redis_version"]) >= ::Gem::Version.new("2.8.0")
      end

      def redis_version_greater_than_3_2_1?
        return @redis_version_greater_than_3_2_1 unless @redis_version_greater_than_3_2_1.nil?

        @redis_version_greater_than_3_2_1 = redis_info_parsed["redis_version"] &&
                                            ::Gem::Version.new(redis_info_parsed["redis_version"]) >= ::Gem::Version.new("3.2.1")
      end

      def set_connection(options = {})
        host = options[:host] || "localhost"
        port = (options[:port] || 6379).to_i

        @connection = ::FFI::HiredisVip::Core.connect(host, port)
      end

      def set_database(options = {})
        database = options[:db]
        raise "Cannot select database specified" if database && !select?(database)
      end

      def set_exists_provider
        @exists_provider = case
                           when redis_version_3?
                             ::FFI::HiredisVip::Exists.new(self)
                           else
                             ::FFI::HiredisVip::ExistsBefore3.new(self)
                           end
      end

      def set_persist_provider
        @persist_provider = case
                            when redis_version_greater_than_2_2?
                              ::FFI::HiredisVip::Persist.new(self)
                            else
                              ::FFI::HiredisVip::PersistBefore22.new(self)
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

      def set_set_provider
        @set_provider = case
                        when redis_version_greater_than_2_6_12?
                          ::FFI::HiredisVip::Set.new(self)
                        else
                          ::FFI::HiredisVip::SetBefore2612.new(self)
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

      def set_touch_provider
        @touch_provider = case
                          when redis_version_greater_than_3_2_1?
                            ::FFI::HiredisVip::Touch.new(self)
                          else
                            ::FFI::HiredisVip::TouchBefore321.new(self)
                          end
      end
    end # class Client
  end # module HiredisVip
end # module FFI
