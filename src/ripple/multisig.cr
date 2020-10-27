require "./response/multisig"
require "./js_class/multisig"

module Ripple::Multisig
  extend self

  def create_signer_list(
    owner_account : NamedTuple(address: String, secret: String),
    signer_accounts : Array(NamedTuple(address: String, weight: Int)),
    quorum : Int32,
    fee : String = ""
  ) : Response::Multisig
    part_code = <<-CODE
      #{JsClass::Multisig.export}
      const m = new Multisig(api);
      const entries = m.createSignerList(#{signer_accounts});
      const txjson = await m.setupMultisig(
        '#{owner_account[:address]}',
        entries,
        #{quorum},
        #{calc_multisig_fee(fee)}
      );
      const res = await m.broadCast(txjson, '#{owner_account[:secret]}');
      toCrystal(res);
    CODE

    code = Ripple.js_main(part_code)
    res = Nodejs.eval(code).to_json
    Ripple.check_response(res)
    Response::Multisig.from_json(res)
  end

  def calc_multisig_fee(fee : String = "") : String
    if fee.empty?
      # 10drops = 0.00001xrp
      # minimum fee
      "10"
    else
      # Convert XRP to drops
      code = Ripple.js_main(
        <<-CODE
      res = api.xrpToDrops('#{fee}');
      toCrystal(res);
      CODE
      )
      Nodejs.eval(code).to_json
    end
  end
end
