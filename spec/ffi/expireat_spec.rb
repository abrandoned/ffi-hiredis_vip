require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new(:host => "127.0.0.1", :port => 6379)
    @client.del("derp")
  end

  after do
    @client.del("derp")
  end

  describe "#expireat" do
    it "returns false when key is not present" do
      @client.expireat("derp", Time.now.to_i).must_equal 0
    end

    it "returns true when key is present and expire is able to be set" do
      @client.set("something", "something")
      @client.expireat("something", Time.now.to_i).must_equal 1
    end
    
    it "removes the key when the expiry is set to previous date/time" do
      @client.set("something", "something")
      @client.expireat("something", 0).must_equal 1
      @client.exists("something").must_equal 0
    end
  end
end
