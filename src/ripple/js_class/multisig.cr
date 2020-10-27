require "./account"

module Ripple::JsClass::Multisig
  extend self

  def export
    <<-CODE
    #{Account.export}
    class Multisig {
      constructor(ripplelib) {
        this.api = ripplelib;
        this.a = new Account(ripplelib);
      }

      createSignerList(signers) {
        if (!Array.isArray(signers) || signers.length == 0 || !signers[0].address || signers[0].weight < 1) {
          throw new Error(`signers is invalid: ${signers}`);
        }
        let signerEntries = [];
        signers.map(signer => {
          let entry = {
            SignerEntry: { Account: signer.address, SignerWeight: signer.weight }
          };
          signerEntries.push(entry);
        });
        return signerEntries;
      }

      async setupMultisig(masterAddress, signerEntries, quorum, fee) {
        if (!quorum || quorum < 1 || !fee) {
          throw new Error(`Set params(quorum, fee) is invalid`);
        }

        if (!Array.isArray(signerEntries) || signerEntries.length == 0) {
          throw new Error(`signerEntries is invalid: ${signerEntries}`);
        }

        if (!this.a.isValidAddress(masterAddress)) {
          throw new Error(`Validate error address: ${masterAddress}`);
        }

        const seq = await this.a.getSequence(masterAddress);
        //todo: what Flags???
        const txjson = {
                Flags: 0,
                TransactionType: "SignerListSet",
                Account: masterAddress,
                Sequence: seq,
                Fee: `${fee}`,
                SignerQuorum: quorum,
                SignerEntries: signerEntries
        };
        return JSON.stringify(txjson);
      }

      async broadCast(txjson, secret) {
        if (!txjson || !secret) {
          throw new Error(`Set params(txjson, secret) is invalid: ${txjson}, ${secret}`);
        }
        if (!this.a.isValidSecret(secret)) {
          throw new Error(`Validate error secret: ${secret}`);
        }
        const signedTx = await this.api.sign(txjson, secret);
        this.firstRes = await this.api.submit(signedTx.signedTransaction);
				// Do verify unnecessary other than tesSUCCESS and tecXXXXX
				if (!this.firstRes.resultCode.match(/^(tec|tes)/)) {
          throw new this.api.errors.RippledError('Failed broadCast', this.firstRes);
        }

        this.a.setInterval(3000);
        return this.verifyTransaction(this.firstRes.tx_json.hash);
      }

      verifyTransaction(hash) {
        console.count("Verify Multisig Transaction loop");
        return this.api.getTransaction(hash).then(resolve => {
          this.firstRes.tx_json.Fee = resolve.outcome.fee;
          this.firstRes.resultCode = resolve.outcome.result;
          return this.firstRes;
        }).catch(e => {
          if (
            e instanceof this.api.errors.MissingLedgerHistoryError ||
            e instanceof this.api.errors.NotFoundError
            ) {
            return new Promise((_, reject) => {
              setTimeout(() => this.verifyTransaction(hash).then(_, reject), 1000);
            });
          }
          throw new Error(e);
        });
      }
    };
    CODE
  end
end
