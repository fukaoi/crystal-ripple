require "../spec_helper"

describe Ripple::Multisig do
  Spec.before_each do
    Ripple.set_network(Ripple::Network::Testnet)
  end

  it "Caluculate fee" do
    fee = Ripple::Multisig.calc_multisig_fee
    fee.should eq "10"
  end

  it "Set calculate fee" do
    target = "0.00002"
    fee = Ripple::Multisig.calc_multisig_fee(target)
    fee.should eq "20"
  end

  it "Create signer list response type:Ripple::Reponse:Multisig" do
    res = Ripple::Multisig.create_signer_list(
      Helper.from_account,
      Helper.extract_secret(Helper.setup_signers(2)),
      2,
      "0.00005"
    )
    res.resultCode.should eq "tesSUCCESS"
    res.tx_json.transaction_type.should eq "SignerListSet"
    res.tx_json.fee.should eq "0.00005"
    p "hash: #{res.tx_json.hash}"
  end

  it "Create signer list response type:Ripple::Reponse:Multisig signers_5" do
    res = Ripple::Multisig.create_signer_list(
      Helper.from_account,
      Helper.extract_secret(Helper.setup_signers(5)),
      5
    )
    res.resultCode.should eq "tesSUCCESS"
    res.tx_json.transaction_type.should eq "SignerListSet"
    res.tx_json.fee.should eq "0.00001"
    p "hash: #{res.tx_json.hash}"
  end
end
