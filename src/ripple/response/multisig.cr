require "json"

module Ripple::Response
  class Multisig
    JSON.mapping(
      resultCode: String,
      resultMessage: String,
      engine_result: String,
      engine_result_code: Float64,
      engine_result_message: String,
      tx_blob: String,
      tx_json: TxJson,
    )

    class TxJson
      include JSON::Serializable

      @[JSON::Field(key: "Account")]
      property account : String

      @[JSON::Field(key: "Fee")]
      property fee : String

      @[JSON::Field(key: "Flags")]
      property flags : Float64

      @[JSON::Field(key: "Sequence")]
      property sequence : Float64

      @[JSON::Field(key: "SignerQuorum")]
      property signer_quorum : Float64

      @[JSON::Field(key: "SigningPubKey")]
      property signing_pub_key : String

      @[JSON::Field(key: "TransactionType")]
      property transaction_type : String

      @[JSON::Field(key: "TxnSignature")]
      property txn_signature : String

      @[JSON::Field(key: "hash")]
      property hash : String

      @[JSON::Field(key: "SignerEntries")]
      property signer_entries : Array(SignerEntries)
    end

    class SignerEntries
      include JSON::Serializable

      @[JSON::Field(key: "SignerEntry")]
      property signer_entry : SignerEntry
    end

    class SignerEntry
      include JSON::Serializable

      @[JSON::Field(key: "Account")]
      property account : String

      @[JSON::Field(key: "SignerWeight")]
      property weight : Float64
    end
  end
end
