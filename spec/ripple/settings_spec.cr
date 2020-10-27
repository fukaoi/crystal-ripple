require "../spec_helper"

describe Ripple::Settings do
  # it "Get settings info at address" do
  # Ripple.set_network(Ripple::Network::Testnet)
  # address = "raNMGRcQ7McWzXYL7LisGDPH5D5Qrtoprp"
  # res = Ripple::Settings.get_settings(address)
  # res.signers.try &.threshold.not_nil!.should be > 0.0
  # res.requireDestinationTag.should be_truthy
  # end

  # it "Get settings no info at address" do
  # Ripple.set_network(Ripple::Network::Testnet)
  # address = "r9gx7ZcvbAPqr1UDWjY4JPbs2zzi4zF3fM"
  # res = Ripple::Settings.get_settings(address)
  # res.defaultRipple.should be_nil
  # end
end
