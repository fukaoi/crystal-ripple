require "nodejs"
require "file_utils"
require "./ripple/response/*"
require "./ripple/*"

module Ripple
  extend self

  enum Network
    Testnet
    Mainnet
  end

  @@network = Network::Testnet
  @@server = ""

  def get_network : NamedTuple(network: String, server: String)
    {network: @@network.to_s.downcase, server: @@server}
  end

  def set_network(network : Network, customize_server : String = "") : Void
    case network
    when Network::Testnet
      @@network = network
      @@server = "wss://s.altnet.rippletest.net:51233"
    when Network::Mainnet
      @@network = network
      @@server = "wss://s1.ripple.com:443"
    end
    unless customize_server.empty?
      @@server = customize_server
    end
  end

  def js_main(code : String) : String
    code = <<-CODE
      #{logger_setup}
      const RippleAPI = require("ripple-lib").RippleAPI;
      let api;
      async function main() {
        try {
          api = new RippleAPI({server: '#{Ripple.get_network[:server]}'});
          await api.connect();
          #{code}
        } catch (e) {
					//#### this point faild transaction ####//
          if (api && e instanceof api.errors.RippledError) {
            if (!e.data.resultCode.match(/^(tec)/)) {
              e.data.tx_json.Fee  = "0"
            }
            toCrystal(e.data);
            process.exit(0);
          }

					//#### this point raise ValidationError ####//
				  if (e instanceof Error) {
						if (e.message.match(/ValidationError(.*)/)) {
            	toCrystal({validError: matched[1]});
						}
						toCrystal({validError: e.message});
            process.exit(0);
					}

					//#### this point raise JSSideException ####//
          toCrystalErr(e);
        } finally {
          await api.disconnect();
          process.exit(0);
        }
      }

      main();
    CODE

    code
  end

  def check_response(res : String) : Void
    if res == "{}"
      raise ResponseError.new("Reponse empty!! please check params, testnet or mainnet")
    end
    check_validation_error(res)
  end

  def check_validation_error(res : String) : Void
    if JSON.parse(res).as_h.has_key?("validError")
      raise ValidationError.new("#{JSON.parse(res)["validError"]}")
    end
  end

  def logger_setup : String
    if ENV["VERBOSE"]? == nil
      <<-CODE
       console.debug = function() {};
       console.count = function() {};
      CODE
    else
      ""
    end
  end

  class ResponseError < Exception; end

  class ValidationError < Exception; end
end
