require "../spec_helper"

# ## ref: https://developers.ripple.com/transaction-results.html
describe Ripple::Payment do
  Spec.before_each do
    Ripple.set_network(Ripple::Network::Testnet)
  end

  it "Caluculate fee" do
    fee = Ripple::Payment.calc_payment_fee("")
    fee.empty?.should be_false
  end

  it "Set calculate fee" do
    target = "0.0002"
    fee = Ripple::Payment.calc_payment_fee(target)
    fee.should eq target
  end
end

describe "Ripple::Payment.send" do
  it "[SUCCESS]Send payment" do
    res = Ripple::Payment.send(
      Helper.from_account,
      Helper.to,
      "1"
    )
    res.resultCode.should eq "tesSUCCESS"
    res.tx_json.fee.should eq "0.00001"
    p "hash: #{res.tx_json.hash}"
  end

  # todo: will do after rafactoring
  # it "[SUCCESS]Require destination tag" do
  # res = Ripple::Payment.send(
  # Helper::Payment.from_account,
  # Helper::Payment.to_req_tag,
  # "1",
  # {source: 777, destination: 999}
  # )
  # res.resultCode.should eq "tesSUCCESS"
  # res.tx_json.fee.should eq "0.00001"
  # res.tx_json.hash.empty?.should be_false
  # p "hash: #{res.tx_json.hash}"
  # end

  # todo: will do after rafactoring
  # it "[ERROR]Require destination tag no set destination tag" do
  # expect_raises(Ripple::ValidationError) do
  # Ripple::Payment.send(
  # Helper::Payment.owner_account,
  # "raNMGRcQ7McWzXYL7LisGDPH5D5Qrtoprp",
  # "1",
  # {source: "444444", destination: ""}
  # )
  # end
  # end

  # todo: will do after rafactoring
  # it "[SUCCESS]Set customize fee, tags, memos" do
  # fee = "0.00002"
  # res = Ripple::Payment.send(
  # Helper::Payment.owner_account,
  # "raNMGRcQ7McWzXYL7LisGDPH5D5Qrtoprp",
  # "1",
  # {source: "410084811", destination: "21002010"},
  # {type: "test", data: "spec demo data", format: "text/plain"},
  # fee
  # )
  # res.resultCode.should eq "tesSUCCESS"
  # res.tx_json.fee.should eq fee
  # res.tx_json.hash.empty?.should be_false
  # p "hash: #{res.tx_json.hash}"
  # end

  it "[SUCCESS]Set ledger_offset = 10" do
    fee = "0.00002"
    res = Ripple::Payment.send(
      Helper.from_account,
      Helper.to,
      "1",
      {source: "", destination: "123457"},
      {type: "", data: "", format: ""},
      fee,
      10
    )
    res.resultCode.should eq "tesSUCCESS"
    res.tx_json.fee.should eq fee
    res.tx_json.hash.empty?.should be_false
    p "hash: #{res.tx_json.hash}"
  end
end

describe "Ripple::Payment.send_by_multisig" do
  it "[SUCCESS] 2signed" do
    res = Ripple::Payment.send_by_multisig(
      Helper.from_account[:address],
      Helper.to,
      "1",
      Helper.signers_2,
    )
    res.resultCode.should eq "tesSUCCESS"
    res.tx_json.fee.should eq "0.00003"
    res.tx_json.hash.empty?.should be_false
    p "hash: #{res.tx_json.hash}"
  end

  it "[SUCCESS]quorum(2) 2 of 3 signed" do
    res = Ripple::Payment.send_by_multisig(
      Helper.from_account[:address],
      Helper.to,
      "1",
      Helper.signers_3.first(2),
    )
    res.resultCode.should eq "tesSUCCESS"
    res.tx_json.fee.should eq "0.00003"
    res.tx_json.hash.empty?.should be_false
    p "hash: #{res.tx_json.hash}"
  end

  # it "[SUCCESS]Require destination tag" do
  # res = Ripple::Payment.send_by_multisig(
  # Helper::Payment.owner_account_2[:address],
  # "raNMGRcQ7McWzXYL7LisGDPH5D5Qrtoprp",
  # "1",
  # Helper::Payment.signers_2,
  # {source: 777, destination: 999}
  # )
  # res.resultCode.should eq "tesSUCCESS"
  # res.tx_json.fee.should eq "0.00003"
  # res.tx_json.hash.empty?.should be_false
  # p "hash: #{res.tx_json.hash}"
  # end

  # it "[ERROR]Require destination tag no set destination tag" do
  # expect_raises(Ripple::ValidationError) do
  # Ripple::Payment.send_by_multisig(
  # Helper::Payment.owner_account_2[:address],
  # "raNMGRcQ7McWzXYL7LisGDPH5D5Qrtoprp",
  # "1",
  # Helper::Payment.signers_2,
  # {source: "444444", destination: ""}
  # )
  # end
  # end

  it "[SUCCESS]Set customize fee, tags, memos" do
    res = Ripple::Payment.send_by_multisig(
      Helper.from_account[:address],
      Helper.to,
      "1",
      Helper.signers_2,
      {source: "410084811", destination: "21002010"},
      {type: "test", data: "spec demo data", format: "text/plain"},
      "0.00002"
    )
    res.resultCode.should eq "tesSUCCESS"
    res.tx_json.fee.should eq "0.00006"
    res.tx_json.hash.empty?.should be_false
    p "hash: #{res.tx_json.hash}"
  end

  it "[SUCCESS]Set ledger_offset=10" do
    res = Ripple::Payment.send_by_multisig(
      Helper.from_account[:address],
      Helper.to,
      "1",
      Helper.signers_3,
      {source: "", destination: ""},
      {type: "", data: "", format: ""},
      "0.00001",
      10
    )
    res.resultCode.should eq "tesSUCCESS"
    res.tx_json.fee.should eq "0.00004"
    res.tx_json.hash.empty?.should be_false
    p "hash: #{res.tx_json.hash}"
  end

  it "[code:tecUNFUNDED_PAYMENT] No enough XRP" do
    from_address = Helper.from_account[:address]
    before_xrp = Helper.get_balance(from_address)
    res = Ripple::Payment.send_by_multisig(
      from_address,
      Helper.to,
      "99999999",
      Helper.signers_2,
    )
    res.resultCode.should eq "tecUNFUNDED_PAYMENT"
    res.tx_json.fee.should eq "0.00003"
    after_xrp = Helper.get_balance(from_address)
    before_xrp.should be > after_xrp
  end

  it "[code:temBAD_AMOUNT] Can only send positive amounts." do
    from_address = Helper.from_account[:address]
    before_xrp = Helper.get_balance(from_address)
    res = Ripple::Payment.send_by_multisig(
      from_address,
      Helper.to,
      "0.00000000000000000000001",
      Helper.signers_2,
    )
    res.resultCode.should eq "temBAD_AMOUNT"
    res.tx_json.fee.should eq "0"
    after_xrp = Helper.get_balance(from_address)
    before_xrp.should be > after_xrp
  end

  it "Large amount: (Fee of 1000 XRP exceeds max of 2 XRP. To use this fee, increase `maxFeeXRP` in the RippleAPI constructor.)" do
    from_address = Helper.from_account[:address]
    before_xrp = Helper.get_balance(from_address)
    expect_raises(Ripple::ValidationError) do
      Ripple::Payment.send_by_multisig(
        from_address,
        Helper.to,
        "9999999999999999999999999999999999999999",
        Helper.signers_2,
      )
    end
    after_xrp = Helper.get_balance(from_address)
    before_xrp.should be > after_xrp
  end

  it "Number of digits (xrpToDrops: value '0.000000000000000001' has too many decimal places.)" do
    from_address = Helper.from_account[:address]
    before_xrp = Helper.get_balance(from_address)
    expect_raises(Ripple::ValidationError) do
      Ripple::Payment.send_by_multisig(
        from_address,
        Helper.to,
        "1",
        Helper.signers_2,
        {source: "", destination: ""},
        {type: "", data: "", format: ""},
        "0.000000000000000001"
      )
    end
    after_xrp = Helper.get_balance(from_address)
    before_xrp.should be > after_xrp
  end

  it "instance.secret does not conform to the secret format" do
    from_address = Helper.from_account[:address]
    before_xrp = Helper.get_balance(from_address)
    expect_raises(Ripple::ValidationError) do
      Ripple::Payment.send_by_multisig(
        from_address,
        Helper.to,
        "1",
        [{address: "", secret: ""}]
      )
    end
    after_xrp = Helper.get_balance(from_address)
    before_xrp.should eq after_xrp
  end

  it "[code:tefNOT_MULTI_SIGNING] Account has no appropriate list of multi-signers" do
    from_address = Helper.from_account[:address]
    before_xrp = Helper.get_balance(from_address)
    res = Ripple::Payment.send_by_multisig(
      from_address,
      Helper.to,
      "1",
      Helper.no_appropriate_signers_2
    )
    res.resultCode.should eq "tefBAD_SIGNATURE"
    res.tx_json.fee.should eq "0"
    after_xrp = Helper.get_balance(from_address)
    before_xrp.should eq after_xrp
  end

  it "[code:telINSUF_FEE_P] Too low fee" do
    from_address = Helper.from_account[:address]
    before_xrp = Helper.get_balance(from_address)
    res = Ripple::Payment.send_by_multisig(
      from_address,
      Helper.to,
      "1",
      Helper.signers_2,
      {source: "", destination: ""},
      {type: "", data: "", format: ""},
      "0.000001",
    )
    res.resultCode.should eq "telINSUF_FEE_P"
    res.tx_json.fee.should eq "0"
    after_xrp = Helper.get_balance(from_address)
    before_xrp.should be > after_xrp
  end

  it "Many number of degits at tag" do
    from_address = Helper.from_account[:address]
    before_xrp = Helper.get_balance(from_address)
    expect_raises(Ripple::ValidationError) do
      Ripple::Payment.send_by_multisig(
        from_address,
        Helper.to,
        "1",
        Helper.signers_2,
        {source: "1234567891011", destination: "777"},
      )
    end
    after_xrp = Helper.get_balance(from_address)
    before_xrp.should be > after_xrp
  end

  it "[code:tefBAD_SIGNATURE] No regist signature" do
    from_address = Helper.from_account[:address]
    before_xrp = Helper.get_balance(from_address)
    res = Ripple::Payment.send_by_multisig(
      from_address,
      Helper.to,
      "1",
      [Helper.signers_2.first]
    )
    res.resultCode.should eq "tefBAD_QUORUM"
    res.tx_json.fee.should eq "0"
    after_xrp = Helper.get_balance(from_address)
    before_xrp.should be > after_xrp
  end
end
