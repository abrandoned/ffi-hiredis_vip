module FFI
  module HiredisVip
    class Info
      attr_reader :original_info, :info_hash

      def initialize(info_string)
        @info_hash = {}
        @original_info = info_string
        process_original_info
      end
      
      def [](key)
        @info_hash[key]
      end

      def method_missing(method_name, *args, &block)
        @info_hash[method_name] || super
      end

      private

      def process_original_info
        original_info.each_line do |info_line|
          next unless info_line.include?(":")

          parts = info_line.split(":")
          @info_hash[parts.shift.strip] = parts.join(":").strip
        end
      end
    end # Info
  end # HiredisVip
end # FFI
