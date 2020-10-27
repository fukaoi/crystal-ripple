require "../spec_helper"

describe Ripple::Account do
  Spec.before_each do
    Ripple.set_network(Ripple::Network::Testnet)
  end

  it "Generate account on testnet" do
    Ripple.set_network(Ripple::Network::Testnet)
    account = Ripple::Account.generate_account
    account.address.empty?.should be_false
    account.secret.empty?.should be_false
  end

  it "Generate account on mainnet" do
    Ripple.set_network(Ripple::Network::Mainnet)
    account = Ripple::Account.generate_account
    account.address.empty?.should be_false
    account.secret.empty?.should be_false
  end

  it "is testnet?" do
    Ripple.set_network(Ripple::Network::Testnet)
    Ripple::Account.is_testnet?.should be_true
  end

  it "no testnet" do
    Ripple.set_network(Ripple::Network::Mainnet)
    Ripple::Account.is_testnet?.should be_false
  end

  it "Get account info" do
    account = Ripple::Account.generate_account
    res = Ripple::Account.get_info(account.address)
    res.xrpBalance.to_i.should be > 0
  end
end
