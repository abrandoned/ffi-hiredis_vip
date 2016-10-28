require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new(:host => "127.0.0.1", :port => 6379)
  end

  describe "#ping" do
    it "returns 'PONG' when server is present" do
      @client.ping.must_equal "PONG"
    end
  end

  describe "#ping?" do
    it "returns true when server is present" do
      @client.ping?.must_equal true
    end
  end
end
