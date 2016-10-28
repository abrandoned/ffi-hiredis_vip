require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new(:host => "127.0.0.1", :port => 6379)
    @client.del("derp")
  end

  after do
    @client.del("derp")
  end

  describe "#incrby" do
    it "returns fresh value of the amount incremented when key is not present" do
      @client.incrby("derp", 5).must_equal 5
    end

    it "returns incremented value when present" do
      @client.set("something", "10")
      @client.incrby("something", 2).must_equal 12
    end

    it "decrements by the amount when the increment amount is negative" do
      @client.set("something", "10")
      @client.incrby("something", -2).must_equal 8
    end

    # TODO: what is the correct behavior here?
    it "returns 0 when value is not incrementable" do
      @client.set("something", "something")
      @client.incrby("something", 1).must_equal 0
    end
  end
end
