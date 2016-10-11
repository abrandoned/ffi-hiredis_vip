require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new("127.0.0.1", 6379)
    @client.flushdb
  end

  describe "#dbsize" do
    it "returns 0 when database is empty" do
      @client.dbsize.must_equal 0
    end

    it "returns the number of keys present when db is not empty" do
      @client.set("something", "something")
      @client.dbsize.must_equal 1
      @client.set("something2", "something")
      @client.dbsize.must_equal 2
    end
  end
end
