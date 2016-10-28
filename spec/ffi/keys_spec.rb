require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new(:host => "127.0.0.1", :port => 6379)
    @client.del("derp")
  end

  after do
    @client.del("derp")
  end

  describe "#keys" do
    it "returns empty array when keys are not present" do
      @client.keys("derp").must_equal []
    end

    it "returns array of key value when key is present" do
      @client.set("something", "something")
      @client.keys("something").must_equal ["something"]
    end

    it "returns array of values if multiple keys that match pattern are present" do
      @client.set("something", "something")
      @client.set("something2", "something")
      @client.set("something3", "something")

      @client.keys("something*").each do |key|
        ["something", "something2", "something3"].must_include key
      end
    end
  end
end
