require 'ffi/hiredis_vip'
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
      end

      def synchronize
        mon_synchronize { yield(@connection) }
      end

      def del(*keys)
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

      def exists(*keys)
        key_size_pairs = []
        number_of_exists = keys.size
        keys.each do |key|
          key_size_pairs << :string << key << :size_t << key.size
        end

        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "EXISTS#{' %b' * number_of_exists}", *key_size_pairs)

          case reply[:type] 
          when :REDIS_REPLY_INTEGER
            reply[:integer]
          else
            0
          end
        end
      end

      def exists?(key)
        exists(key) == 1
      end

      def ping
        synchronize do |connection|
          reply = ::FFI::HiredisVip::Core.command(connection, "PING")

          case reply[:type] 
          when :REDIS_REPLY_STRING
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
    end
  end
end
