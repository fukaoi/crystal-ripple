require "json"

module Ripple::Response
  class Verify
    JSON.mapping(
      type: String,
      address: String,
      sequence: Float64,
      id: String,
      specification: Specification?,
      outcome: Outcome,
    )
  end

  class Maxamount
    JSON.mapping(
      currency: String,
      value: String,
    )
  end

  class Source
    JSON.mapping(
      address: String,
      maxAmount: Maxamount,
    )
  end

  class Destination
    JSON.mapping(
      address: String,
    )
  end

  class Specification
    JSON.mapping(
      source: Source?,
      destination: Destination?,
    )
  end

  class Deliveredamount
    JSON.mapping(
      currency: String,
      value: String,
    )
  end

  class Outcome
    JSON.mapping(
      result: String,
      timestamp: String,
      fee: String,
      ledgerVersion: Float64,
      indexInLedger: Float64,
      deliveredAmount: Deliveredamount?,
    )
  end
end
