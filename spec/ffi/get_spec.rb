require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new(:host => "127.0.0.1", :port => 6379)
    @client.del("derp")
  end

  after do
    @client.del("derp")
  end

  describe "#get" do
    it "returns nil when key is not present" do
      @client.get("derp").must_equal nil
    end

    it "returns set value when key is present" do
      @client.set("something", "something")
      @client.get("something").must_equal "something"
    end
  end
end
