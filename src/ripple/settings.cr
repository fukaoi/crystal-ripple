require "./response/settings"

module Ripple::Settings
  extend self

  def get_settings(address : String) : Response::Settings
    code = Ripple.js_main(
      <<-CODE
      const address = '#{address}'
      if (!api.isValidAddress(address)) {
        throw new Error(`Validate error address: ${address}`);
      }
      const res = await api.getSettings(address);
      if (Object.keys(res).length !== 0) {
		    toCrystal(res);
      }
		CODE
    )
    res = Nodejs.eval(code).to_json
    Ripple.check_validation_error(res)
    Response::Settings.from_json(res)
  end

  def is_require_dest_tag?(address : String) : Bool
    res = get_settings(address)
    res.requireDestinationTag == true
  end
end
