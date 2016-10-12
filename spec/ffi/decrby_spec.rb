require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new("127.0.0.1", 6379)
    @client.del("derp")
  end

  after do
    @client.del("derp")
  end

  describe "#decrby" do
    it "returns fresh value of negative decrement amount when key is not present" do
      @client.decrby("derp", 5).must_equal -5
    end

    it "returns decremented value when present" do
      @client.set("something", "10")
      @client.decrby("something", 2).must_equal 8
    end

    it "increments by the amount when the amount is negative" do
      @client.set("something", "10")
      @client.decrby("something", -2).must_equal 12
    end

    # TODO: what is the correct behavior here?
    it "returns 0 when value is not decrementable" do
      @client.set("something", "something")
      @client.decrby("something", 1).must_equal 0
    end
  end
end
