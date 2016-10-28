require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new(:host => "127.0.0.1", :port => 6379)
    @client.del("derp")
  end

  after do
    @client.del("derp")
  end

  describe "#mget" do
    it "returns array of nil when key is not present" do
      @client.mget("derp").must_equal [nil]
    end

    it "returns array of set value when key is present" do
      @client.set("something", "something")
      @client.mget("something").must_equal ["something"]
    end

    it "returns array of set value and nil if one key not defined" do
      @client.set("something", "something")
      @client.mget("something", "derp").must_equal ["something", nil]
    end

    it "returns array ordered by inputs of set value and nil if one key not defined" do
      @client.set("something", "something")
      @client.mget("something", "derp", "something").must_equal ["something", nil, "something"]
    end
  end
end
