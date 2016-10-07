require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new("127.0.0.1", 6379)
    @client.del("derp", "nothing")
  end

  after do
    @client.del("derp", "nothing")
  end

  describe "#exists" do
    it "returns 0 when key is not present" do
      @client.exists("derp").must_equal 0
    end

    it "returns 1 when single key is present" do
      @client.set("something", "something")
      @client.exists("something").must_equal 1
    end

    it "returns the number of keys that are present when multiple keys sent" do
      @client.set("derp", "derp")
      @client.set("something", "something")
      @client.exists("derp", "something").must_equal 2
    end

    it "does not return a key that does not exist" do
      @client.set("derp", "derp")
      @client.set("something", "something")
      @client.exists("derp", "something", "nothing").must_equal 2
    end
  end
end
