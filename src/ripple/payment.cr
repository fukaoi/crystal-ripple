require "./response/payment"
require "./response/verify"
require "./js_class/payment"

module Ripple::Payment
  extend self

  LEDGER_OFFSET = 5

  def send(owner_account : {address: String, secret: String},
           to_address : String,
           amount : String,
           tags = {source: "", destination: ""},     # optional
           memos = {type: "", format: "", data: ""}, # optional
           fee : String = "",                        # optional
           ledger_offset : Int32 = LEDGER_OFFSET     # optional
           ) : Response::Payment
    check_require_dest(to_address, tags[:destination])

    code = Ripple.js_main(
      <<-CODE
      #{JsClass::Payment.export}
      const p = new Payment(api, '#{owner_account[:address]}', #{ledger_offset});
      const tx = p.createTransaction('#{amount}', '#{to_address}', #{tags}, #{memos});
      const res = await p.broadCast(tx, '#{calc_payment_fee(fee)}', '#{owner_account[:secret]}');
      toCrystal(res);
      CODE
    )

    res = Nodejs.eval(code).to_json
    Ripple.check_response(res)
    Response::Payment.from_json(res)
  end

  def send_by_multisig(from_address : String,
                       to_address : String,
                       amount : String,
                       signer_accounts : Array(NamedTuple(address: String, secret: String)),
                       tags = {source: "", destination: ""},     # optional
                       memos = {type: "", format: "", data: ""}, # optional
                       fee : String = "",                        # optional
                       ledger_offset : Int32 = LEDGER_OFFSET     # optional
                       ) : Response::Payment
    check_require_dest(to_address, tags[:destination])

    code = Ripple.js_main(
      <<-CODE
      #{JsClass::Payment.export}
      const p = new Payment(api, '#{from_address}', #{ledger_offset});
      const tx = p.createTransaction('#{amount}', '#{to_address}', #{tags}, #{memos});
      const txRaw = await p.prepare(tx, #{calc_payment_fee(fee)}, #{signer_accounts.size});
      const signeds = await p.setupSignerSignning(txRaw.txJSON, #{signer_accounts});
      const res = await p.broadCastWithMultisig(signeds, txRaw);
      toCrystal(res);
    CODE
    )

    res = Nodejs.eval(code).to_json
    Ripple.check_response(res)
    Response::Payment.from_json(res)
  end

  def calc_payment_fee(fee : String) : String
    if fee.empty?
      # 10drops = 0.00001xrp
      # if signers 3, 0.00001 * 4
      "0.00001"
    else
      fee
    end
  end

  def check_require_dest(to_address : String, dest_tag : String | Int32) : Void
    if dest_tag.to_s.empty?
      if Settings.is_require_dest_tag?(to_address)
        raise Ripple::ValidationError.new("Require destination tag, but no set destination tag")
      end
    end
  end
end
