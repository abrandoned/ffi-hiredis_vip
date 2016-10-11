require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new("127.0.0.1", 6379)
    @client.del("derp", "something")
  end

  after do
    @client.del("derp", "something")
  end

  describe "#ttl" do
    it "returns -2 when key is not present" do
      @client.ttl("derp").must_equal -2
    end

    it "returns associated expire when set" do
      @client.set("something", "something")
      @client.expire("something", 10).must_equal 1
      @client.expire?("something", 10).must_equal true
      @client.ttl("something").must_equal 10
    end

    it "returns -1 when no associated expire" do
      @client.set("something", "something")
      @client.ttl("something").must_equal -1
    end
  end
end
