module FFI
  module HiredisVip
    class SetBefore2612
      def initialize(client)
        @client = client
      end
      
      def psetex(key, value, expiry)
        expiry = "#{expiry}"
        reply = nil
        value = value.to_s
        command = "PSETEX %b %b %b"
        command_args = [ :pointer, key, :size_t, key.size, :string, expiry, :size_t, expiry.size, :pointer, value, :size_t, value.size ]

        synchronize do |connection|
          reply = @client.execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type] 
        when :REDIS_REPLY_STRING
          reply[:str].dup
        when :REDIS_REPLY_STATUS
          reply[:str].dup
        when :REDIS_REPLY_NIL
          nil
        else
          ""
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply.pointer) if reply
      end

      def set(key, value, options = {})
        reply = nil
        value = value.to_s
        command = "SET %b %b"
        command_args = [ :pointer, key, :size_t, key.size, :pointer, value, :size_t, value.size ]

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
          reply[:str].dup
        when :REDIS_REPLY_STATUS
          reply[:str].dup
        when :REDIS_REPLY_NIL
          nil
        else
          ""
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply) if reply
      end

      def setex(key, value, expiry)
        expiry = "#{expiry}"
        reply = nil
        value = value.to_s
        command = "SETEX %b %b %b"
        command_args = [ :pointer, key, :size_t, key.size, :string, expiry, :size_t, expiry.size, :pointer, value, :size_t, value.size ]

        synchronize do |connection|
          reply = @client.execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type] 
        when :REDIS_REPLY_STRING
          reply[:str].dup
        when :REDIS_REPLY_STATUS
          reply[:str].dup
        when :REDIS_REPLY_NIL
          nil
        else
          ""
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply) if reply
      end

      def setnx(key, value)
        reply = nil
        value = value.to_s
        command = "SETNX %b %b"
        command_args = [ :pointer, key, :size_t, key.size, :pointer, value, :size_t, value.size ]

        synchronize do |connection|
          reply = @client.execute_command(connection, command, *command_args)
        end

        return nil if reply.nil? || reply.null?

        case reply[:type] 
        when :REDIS_REPLY_STRING
          reply[:str].dup
        when :REDIS_REPLY_STATUS
          reply[:str].dup
        when :REDIS_REPLY_NIL
          nil
        else
          ""
        end
      ensure
        ::FFI::HiredisVip::Core.freeReplyObject(reply) if reply
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
