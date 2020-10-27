require "json"
require "./memos"

module Ripple::Response
  class Settings
    JSON.mapping(
      defaultRipple: Bool?,
      depositAuth: Bool?,
      disableMasterKey: Bool?,
      disallowIncomingXRP: Bool?,
      domain: String?,
      emailHash: String?,
      enableTransactionIDTracking: Bool?,
      globalFreeze: Bool?,
      memos: Memos?,
      messageKey: String?,
      noFreeze: Bool?,
      passwordSpent: Bool?,
      regularKey: String?,
      requireAuthorization: Bool?,
      requireDestinationTag: Bool?,
      signers: Signers?,
      transferRate: Int32?
    )

    class Signers
      JSON.mapping(
        threshold: Float64?,
        weights: Array(Weights)?
      )
    end

    class Weights
      JSON.mapping(
        address: String?,
        weight: Float64?
      )
    end
  end
end
