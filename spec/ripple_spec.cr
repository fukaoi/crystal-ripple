require "./spec_helper"

describe Ripple do
  it "Setter, Getter network, server[testnet]" do
    Ripple.set_network(Ripple::Network::Testnet)
    res = Ripple.get_network
    res[:network].should eq "testnet"
    res[:server].should eq "wss://s.altnet.rippletest.net:51233"
  end

  it "Setter, Getter network, server[mainnet]" do
    Ripple.set_network(Ripple::Network::Mainnet)
    res = Ripple.get_network
    res[:network].should eq "mainnet"
    res[:server].should eq "wss://s1.ripple.com:443"
  end

  it "Setter, Getter network, server[testnet] and set server url" do
    Ripple.set_network(Ripple::Network::Testnet, "wss://localhost")
    res = Ripple.get_network
    res[:network].should eq "testnet"
    res[:server].should eq "wss://localhost"
  end

  it "Ripple API cant connected web socket server: does not match pattern ^(wss?|wss?\\+unix)://" do
    Ripple.set_network(Ripple::Network::Testnet, "http://example.org")
    expect_raises(Ripple::ValidationError) do
      code = Ripple.js_main("console.log('spec')")
      res = Nodejs.eval(code).to_json
      Ripple.check_validation_error(res)
    end
  end

  it "Check validation error" do
    mess = "{\"validError\":\"spec test\"}"
    expect_raises(Ripple::ValidationError, "spec test") do
      Ripple.check_validation_error(mess)
    end
  end

  it "Check validation error, no match" do
    mess = "{\"result\":10}"
    Ripple.check_validation_error(mess)
  end
end
