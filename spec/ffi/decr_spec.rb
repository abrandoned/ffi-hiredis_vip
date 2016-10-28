require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new(:host => "127.0.0.1", :port => 6379)
    @client.del("derp")
  end

  after do
    @client.del("derp")
  end

  describe "#decr" do
    it "returns fresh value of -1 when key is not present" do
      @client.decr("derp").must_equal -1
    end

    it "returns decremented value when present" do
      @client.set("something", "10")
      @client.decr("something").must_equal 9
    end

    # TODO: what is the correct behavior here?
    it "returns 0 when value is not decrementable" do
      @client.set("something", "something")
      @client.decr("something").must_equal 0
    end
  end
end
