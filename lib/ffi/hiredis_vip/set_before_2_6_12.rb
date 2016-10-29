module FFI
  module HiredisVip
    class SetBefore2612
      def initialize(client)
        @client = client
      end
      
      def psetex(key, value, expiry)
        expiry = "#{expiry}"
        reply = nil
        command = "PSETEX %b %b %b"
        command_args = [ :string, key, :size_t, key.size, :string, expiry, :size_t, expiry.size, :string, value, :size_t, value.size ]

        synchronize do |connection|
          reply = @client.execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type] 
        when :REDIS_REPLY_STRING
          reply[:str]
        when :REDIS_REPLY_STATUS
          reply[:str]
        when :REDIS_REPLY_NIL
          nil
        else
          ""
        end
      end

      def set(key, value, options = {})
        reply = nil
        command = "SET %b %b"
        command_args = [ :string, key, :size_t, key.size, :string, value, :size_t, value.size ]

        case
        when options[:ex]
          return setex(key, value, options[:ex])
        when options[:px]
          return psetex(key, value, options[:ex])
        when options[:nx]
          return setnx(key, value)
        end
        
        synchronize do |connection|
          reply = @client.execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type] 
        when :REDIS_REPLY_STRING
          reply[:str]
        when :REDIS_REPLY_STATUS
          reply[:str]
        when :REDIS_REPLY_NIL
          nil
        else
          ""
        end
      end

      def setex(key, value, expiry)
        expiry = "#{expiry}"
        reply = nil
        command = "SETEX %b %b %b"
        command_args = [ :string, key, :size_t, key.size, :string, expiry, :size_t, expiry.size, :string, value, :size_t, value.size ]

        synchronize do |connection|
          reply = @client.execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type] 
        when :REDIS_REPLY_STRING
          reply[:str]
        when :REDIS_REPLY_STATUS
          reply[:str]
        when :REDIS_REPLY_NIL
          nil
        else
          ""
        end
      end

      def setnx(key, value)
        reply = nil
        command = "SETNX %b %b"
        command_args = [ :string, key, :size_t, key.size, :string, value, :size_t, value.size ]

        synchronize do |connection|
          reply = @client.execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type] 
        when :REDIS_REPLY_STRING
          reply[:str]
        when :REDIS_REPLY_STATUS
          reply[:str]
        when :REDIS_REPLY_NIL
          nil
        else
          ""
        end
      end

      private

      def synchronize
        @client.synchronize do |connection|
          yield(connection)
        end
      end

    end # class SetBefore2612
  end # module HiredisVip
end # module FFI
