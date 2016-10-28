require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new(:host => "127.0.0.1", :port => 6379)
    @client.del("derp")
  end

  after do
    @client.del("derp")
  end

  describe "#expire" do
    it "returns 0 when key is not present" do
      @client.expire("derp", 10).must_equal 0
    end

    it "returns 1 when key is present and expire is able to be set" do
      @client.set("something", "something")
      @client.expire("something", 10).must_equal 1
      @client.ttl("something").must_equal 10
    end
  end

  describe "#expire?" do
    it "returns false when key is not present" do
      @client.expire?("derp", 10).must_equal false
    end

    it "returns true when key is present and expire is able to be set" do
      @client.set("something", "something")
      @client.expire?("something", 10).must_equal true
      @client.ttl("something").must_equal 10
    end
  end
end
