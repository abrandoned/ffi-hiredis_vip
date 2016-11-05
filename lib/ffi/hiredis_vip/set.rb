module FFI
  module HiredisVip
    class Set
      def initialize(client)
        @client = client
      end

      def psetex(key, value, expiry)
        set(key, value, :px => expiry)
      end

      def set(key, value, options = {})
        reply = nil
        command = "SET %b %b"
        value = value.to_s
        command_args = [ :string, key, :size_t, key.size, :string, value, :size_t, value.size ]

        if options[:ex]
          expiry = "#{options[:ex]}"
          command << " EX %b"
          command_args << :string << expiry << :size_t << expiry.size
        end

        if options[:px]
          px_expiry = "#{options[:px]}"
          command << " PX %b"
          command_args << :string << px_expiry << :size_t << px_expiry.size
        end
        
        command << " NX" if options[:nx]
        command << " XX" if options[:xx]

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
        set(key, value, :ex => expiry)
      end

      def setnx(key, value)
        set(key, value, :nx => true)
      end

      private

      def synchronize
        @client.synchronize do |connection|
          yield(connection)
        end
      end

    end # class Set
  end # module HiredisVip
end # module FFI
