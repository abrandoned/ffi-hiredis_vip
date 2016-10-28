require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new(:host => "127.0.0.1", :port => 6379)
    @client.del("derp", "nothing")
  end

  after do
    @client.del("derp", "nothing")
  end

  describe "#del" do
    it "returns 0 when key is not present" do
      @client.del("derp").must_equal 0
    end

    it "returns 1 when single key is deleted (and 0 after deletion)" do
      @client.set("something", "something")
      @client.del("something").must_equal 1
      @client.del("something").must_equal 0
    end

    it "returns the number of keys that are deleted when multiple keys sent" do
      @client.set("derp", "derp")
      @client.set("something", "something")
      @client.del("derp", "something").must_equal 2
    end

    it "does not return an increment for a key that does not exist" do
      @client.set("derp", "derp")
      @client.set("something", "something")
      @client.del("derp", "something", "nothing").must_equal 2
    end
  end
end
