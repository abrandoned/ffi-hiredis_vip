require 'spec_helper'

describe ::FFI::HiredisVip::Client do
  before do
    @client = ::FFI::HiredisVip::Client.new("127.0.0.1", 6379)
    @client.del("derp", "nothing")
  end

  after do
    @client.del("derp", "nothing")
  end

  #  TODO: Figure out how to replicate in < 3.2.1 or run different specs
#  describe "#touch" do
#    it "returns 0 when key is not present" do
#      @client.touch("derp").must_equal 0
#    end
#
#    it "returns 1 when single key is touched" do
#      @client.set("something", "something")
#      @client.touch("something").must_equal 1
#    end
#
#    it "returns the number of keys that are touched when multiple keys sent" do
#      @client.set("derp", "derp")
#      @client.set("something", "something")
#      @client.touch("derp", "something").must_equal 2
#    end
#
#    it "does not return an increment for a key that does not exist" do
#      @client.set("derp", "derp")
#      @client.set("something", "something")
#      @client.touch("derp", "something", "nothing").must_equal 2
#    end
#  end
end
