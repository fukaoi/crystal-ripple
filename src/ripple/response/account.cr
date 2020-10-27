require "json"

module Ripple::Response
  class Account
    JSON.mapping(
      address: String,
      secret: String
    )

    class Info
      JSON.mapping(
        sequence: Float64,
        xrpBalance: String,
        ownerCount: Float64,
        previousAffectingTransactionID: String,
        previousAffectingTransactionLedgerVersion: Float64,
      )
    end
  end
end
