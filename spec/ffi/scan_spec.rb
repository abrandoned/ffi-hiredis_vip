require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new(:host => "127.0.0.1", :port => 6379)
    @client.flushdb
  end

  after do
    @client.flushdb
  end

  describe "#scan" do
    it "returns all keys currently in DB and '0' cursor on complete" do
      @client.set("derp", "something")
      @client.set("derp2", "something")
      @client.set("derp3", "something")

      res = @client.scan("0")
      res[0].must_equal "0"

      ["derp", "derp2", "derp3"].each do |value|
        res[1].must_include value
      end
    end
  end

  describe "#scan_each" do
    it "iterates through all keys currently in DB" do
      @client.set("derp", "something")
      @client.set("derp2", "something")
      @client.set("derp3", "something")

      @client.scan_each do |value|
        ["derp", "derp2", "derp3"].must_include value
      end
    end

    it "iterates through all keys currently in DB that match matcher" do
      @client.set("derp", "something")
      @client.set("derp2", "something")
      @client.set("derp3", "something")

      @client.scan_each(:match => "derp?") do |value|
        ["derp2", "derp3"].must_include value
      end
    end
  end
end
