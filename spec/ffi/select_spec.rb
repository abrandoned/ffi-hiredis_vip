require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new(:host => "127.0.0.1", :port => 6379)
    @client.del("derp", "something")
  end

  after do
    @client.del("derp", "something")
  end

  describe "#select" do
    it "returns OK when integer db is selected" do
      @client.select(0).must_equal "OK"
    end

    it "returns OK when string db is selected" do
      @client.select("0").must_equal "OK"
    end

    it "returns nil when db cannot be selected" do
      @client.select(12345566).must_equal nil
    end
  end
end
