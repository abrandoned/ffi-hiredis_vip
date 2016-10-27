require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new("127.0.0.1", 6379)
    @client.del("derp")
  end

  after do
    @client.del("derp")
  end

  describe "#set" do
    it "returns 'OK' when successful" do
      @client.set("derp", "derp").must_equal "OK"
    end
  end

  describe "#set?" do
    it "returns true when successful" do
      @client.set?("derp", "derp").must_equal true
    end
  end

  describe "setex" do
    it "returns 'OK' when successful" do
      @client.setex("derp", "derp", 10).must_equal "OK"
    end

    it "sets the TTL on the key" do
      @client.setex("derp", "derp", 10)
      @client.ttl("derp").must_be_close_to 10
    end
  end
end
