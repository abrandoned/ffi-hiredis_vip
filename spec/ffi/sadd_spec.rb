require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new("127.0.0.1", 6379)
    @client.del("derp", "nothing")
  end

  after do
    @client.del("derp", "nothing")
  end

  describe "#sadd" do
    it "returns 1 when single key is added to set" do
      @client.sadd("derp", "something").must_equal 1
    end

    it "returns the number of keys that added to set when multiple keys sent" do
      @client.sadd("derp", "derp", "derp", "derp", "derp").must_equal 1
      @client.sadd("derp", "derp2", "derp3").must_equal 2
    end
  end
end
