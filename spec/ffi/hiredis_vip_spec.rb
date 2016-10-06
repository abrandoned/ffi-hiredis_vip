require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new("127.0.0.1", 6379)
  end

  describe "#get" do
    it "returns nil when key is not present" do
      @client.del("derp")
      @client.get("derp").must_equal nil
    end

    it "returns set value when key is present" do
      @client.set("something", "something")
      @client.get("something").must_equal "something"
    end
  end
end
