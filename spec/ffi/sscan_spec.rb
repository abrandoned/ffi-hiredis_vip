require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new("127.0.0.1", 6379)
    @client.flushdb
  end

  after do
    @client.flushdb
  end

  describe "#sscan" do
    it "returns all members of set currently in DB and '0' cursor on complete" do
      @client.sadd("derp", "something")
      @client.sadd("derp", "something2")
      @client.sadd("derp", "something3")

      res = @client.sscan("derp", "0")
      res[0].must_equal "0"

      ["something", "something2", "something3"].each do |value|
        res[1].must_include value
      end
    end
  end

  describe "#sscan_each" do
    it "iterates through all values of a set currently in DB" do
      @client.sadd("derp", "something")
      @client.sadd("derp", "something2")
      @client.sadd("derp", "something3")

      @client.sscan_each("derp") do |value|
        ["something", "something2", "something3"].must_include value
      end
    end

    it "iterates through all values currently in DB that match matcher" do
      @client.sadd("derp", "something")
      @client.sadd("derp", "something2")
      @client.sadd("derp", "something3")

      @client.sadd("derp2", "1something")
      @client.sadd("derp2", "2something2")
      @client.sadd("derp2", "3something3")

      @client.sscan_each("derp?") do |value|
        ["1something", "2something2", "3something3"].must_include value
      end
    end
  end
end
