require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new(:host => "127.0.0.1", :port => 6379)
    @client.del("derp", "something")
  end

  after do
    @client.del("derp", "something")
  end

  describe "#persist" do
    it "returns 0 when key is not present" do
      @client.persist("derp").must_equal 0
    end

    it "returns 1 when key is present and persist succeeds" do
      @client.set("something", "something")
      @client.expire("something", 10).must_equal 1
      @client.persist("something").must_equal 1
      @client.ttl("something").must_equal -1
    end
  end

  describe "#persist?" do
    it "returns false when key is not present" do
      @client.persist?("derp").must_equal false
    end

    it "returns true when key is present and persist is able to be set" do
      @client.set("something", "something")
      @client.expire("something", 10).must_equal 1
      @client.persist?("something").must_equal true
    end

    it "returns true when key is present and ttl is not set" do
      @client.set("something", "something")
      @client.persist?("something").must_equal true
    end
  end
end
