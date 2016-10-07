require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new("127.0.0.1", 6379)
    @client.del("derp")
  end

  after do
    @client.del("derp")
  end

  describe "#set" do
    it "returns true when successful" do
      @client.set("derp", "derp").must_equal true
    end
  end
end
