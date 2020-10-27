require "json"

module Ripple::Response
  class Payment
    JSON.mapping(
      resultCode: String,
      resultMessage: String,
      engine_result: String,
      engine_result_code: Float64,
      engine_result_message: String,
      tx_blob: String,
      tx_json: TxJson,
    )
  end

  class Signer
    include JSON::Serializable

    @[JSON::Field(key: "Account")]
    property account : String

    @[JSON::Field(key: "SigningPubKey")]
    property signing_pub_key : String

    @[JSON::Field(key: "TxnSignature")]
    property txn_signature : String
  end

  class Signers
    include JSON::Serializable

    @[JSON::Field(key: "Signer")]
    property signer : Signer
  end

  class TxJson
    include JSON::Serializable

    @[JSON::Field(key: "Account")]
    property account : String

    @[JSON::Field(key: "Amount")]
    property amount : String

    @[JSON::Field(key: "Fee")]
    property fee : String

    @[JSON::Field(key: "Flags")]
    property flags : Float64

    @[JSON::Field(key: "Sequence")]
    property sequence : Float64

    @[JSON::Field(key: "Destination")]
    property destination : String

    @[JSON::Field(key: "LastLedgerSequence")]
    property last_ledger_sequence : Float64

    @[JSON::Field(key: "TransactionType")]
    property transaction_type : String

    @[JSON::Field(key: "Signers")]
    property signers : Array(Signers)?

    @[JSON::Field(key: "hash")]
    property hash : String

    @[JSON::Field(key: "SigningPubKey")]
    property signing_pub_key : String
  end
end
