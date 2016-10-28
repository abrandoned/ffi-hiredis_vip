require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new(:host => "127.0.0.1", :port => 6379)
  end

  describe "#echo" do
    it "returns value sent when server echos" do
      @client.echo("PONG").must_equal "PONG"
    end
  end

  describe "#echo?" do
    it "returns true when echo succeeds" do
      @client.echo?("PONG").must_equal true
    end
  end
end
