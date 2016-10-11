require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new("127.0.0.1", 6379)
    @client.del("derp")
  end

  after do
    @client.del("derp")
  end

  describe "#incr" do
    it "returns fresh value of 1 when key is not present" do
      @client.incr("derp").must_equal 1
    end

    it "returns incremented value when present" do
      @client.set("something", "10")
      @client.incr("something").must_equal 11
    end

    # TODO: what is the correct behavior here?
    it "returns 0 when value is not incrementable" do
      @client.set("something", "something")
      @client.incr("something").must_equal 0
    end
  end
end
