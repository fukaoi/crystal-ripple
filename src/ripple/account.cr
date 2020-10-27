require "./response/account"
require "./js_class/account"

module Ripple::Account
  extend self

  def get_info(address : String) : Response::Account::Info
    code = Ripple.js_main(
      <<-CODE
      const address = '#{address}'
      if (!api.isValidAddress(address)) {
        throw new Error(`Validate error address: ${address}`);
      }
      const res = await api.getAccountInfo(address);
		  toCrystal(res);
		CODE
    )
    res = Nodejs.eval(code).to_json
    Ripple.check_response(res)
    Response::Account::Info.from_json(res)
  end

  def generate_account : Response::Account
    if is_testnet?
      part_code = <<-CODE
        #{JsClass::Account.export}
        const a = new Account(api);
        toCrystal(await a.newAccountTestnet());
      CODE
    else
      part_code = <<-CODE
        #{JsClass::Account.export}
        const a = new Account(api);
        toCrystal(await a.newAccount());
      CODE
    end
    code = Ripple.js_main(part_code)
    res = Nodejs.eval(code).to_json
    Ripple.check_response(res)
    Response::Account.from_json(res)
  end

  def is_testnet?
    testnet_str = Network::Testnet.to_s.downcase
    Ripple.get_network[:network] == testnet_str
  end
end
