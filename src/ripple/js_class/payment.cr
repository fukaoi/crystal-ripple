module Ripple::JsClass::Payment
  extend self

  def export
    <<-CODE
    #{JsClass::Account.export}
    const BigNumber = require("bignumber.js");

    class Payment {
      constructor(ripplelib, masterAddress, ledgerOffset) {
        this.api = ripplelib;
        this.a = new Account(ripplelib);
        this.masterAddress = masterAddress;
        this.ledgerOffset =  ledgerOffset
        this.interval = 3000;
      }

      createTransaction(
        amount,
        toAddress,
        tags = {source: 0, destination: 0},
        memos = [],
      ) {
        if (!amount || amount < 0) {
          throw new Error(`amount is invalid: ${amount}`);
        }
        if (!this.a.isValidAddress(toAddress)) {
          throw new Error(`Validate error address: ${toAddress}`);
        }

        let sobj = {
          source: {
            address: this.masterAddress,
            amount: { value: `${amount}`, currency: "XRP" }
          }
        };

        // source tag
        const sourceId = parseInt(tags.source);
        if (sourceId > 0) sobj.source.tag = sourceId;

        let dobj = {
          destination: {
            address: toAddress,
            // minAmount:   {value: '' + amount, currency: 'XRP' }} // check, need???
            minAmount: { value: `${amount}`, currency: "XRP" }
          }
        };

        // destination tag
        const destinationId = parseInt(tags.destination);
        if (destinationId > 0) dobj.destination.tag = destinationId;
        let merged = Object.assign(sobj, dobj);

        // Memo
        if (memos.length) merged.memos = memos;

        return merged;
      }

      async prepare(tx, fee, signersCount) {
        if (!tx || !fee || fee < 0) {
          throw new Error(`Set params(tx, fee) is invalid: ${tx}, ${fee}`);
        }
        const seq = await this.a.getSequence(this.masterAddress);
        const instructions = {
          fee: `${fee}`,
          sequence: seq,
          signersCount: signersCount,
          maxLedgerVersionOffset: this.ledgerOffset,
        };

        const txRaw = await this.api.preparePayment(
          this.masterAddress,
          tx,
          instructions
        );

        // debug
        this.logLedgerVersion(txRaw);

        return txRaw;
      }

      async setupSignerSignning(json, regularKeys) {
        if (!json || !Array.isArray(regularKeys) || regularKeys.length == 0) {
          throw new Error(`Set params(json, regularKeys) is invalid: ${json}, ${regularKeys}`);
        }
        let signeds = [];
        regularKeys.forEach(async (key) => {
          let signed = await this.api.sign(json, key.secret, { signAs: key.address });
          signeds.push(signed);
        });
        return signeds;
      }

      async broadCast(tx, fee, secret) {
        if (!tx || !fee) {
          throw new Error(`Set params(tx, fee) is invalid: ${tx}, ${fee}`);
        }
        const seq = await this.a.getSequence(this.masterAddress);
        const instructions = {
          fee: `${fee}`,
          sequence: seq,
          maxLedgerVersionOffset: this.ledgerOffset,
        };


        const txRaw = await this.api.preparePayment(
          this.masterAddress,
          tx,
          instructions
        );

        // debug
        this.logLedgerVersion(txRaw);

        const signed = await this.api.sign(txRaw.txJSON, secret);
        this.firstRes = await this.api.submit(signed.signedTransaction);
        // Do verify unnecessary other than tesSUCCESS and tecXXXXX
        if (!this.firstRes.resultCode.match(/^(tec|tes)/)) {
          throw new this.api.errors.RippledError('Failed broadCastWithVerify', this.firstRes);
        }

        const options = await this.setLedgerOptions(txRaw);

        this.a.setInterval(this.interval);
        return this.verifyTransaction(this.firstRes.tx_json.hash, options);
       }

      async broadCastWithMultisig(signeds, prepared) {
        if (!Array.isArray(signeds) || signeds.length == 0) {
          throw new Error(`Signeds is invalid: ${signeds}`);
        }
        const setupCombine = (signeds) => {
          return signeds.map(sig => {
            return sig.signedTransaction;
          });
        };
        const combined = this.api.combine(setupCombine(signeds));
        this.firstRes = await this.api.submit(combined.signedTransaction);
				// Do verify unnecessary other than tesSUCCESS and tecXXXXX
				if (!this.firstRes.resultCode.match(/^(tec|tes)/)) {
          throw new this.api.errors.RippledError('Failed broadCastWithVerify', this.firstRes);
        }

        const options = await this.setLedgerOptions(prepared);

        this.a.setInterval(this.interval);
        return this.verifyTransaction(this.firstRes.tx_json.hash, options);
      }

      verifyTransaction(hash, options) {
        console.count("Verify Payment Transaction loop");
        return this.api.getTransaction(hash, options).then(resolve => {
          this.firstRes.tx_json.Fee = resolve.outcome.fee;
          this.firstRes.resultCode = resolve.outcome.result;
          return this.firstRes;
        }).catch(e => {
          if (e instanceof this.api.errors.PendingLedgerVersionError) {
            return new Promise((_, reject) => {
              setTimeout(() => this.verifyTransaction(hash, options).then(_, reject), 1000);
            });
          }
          throw new Error(e);
        });
      }

      async logLedgerVersion(txRaw) {
        console.debug('--------------------------');
        console.debug(`LastLedgerSequence: ${txRaw.instructions.maxLedgerVersion}`);
        console.debug(`CurrentLedger:      ${await this.api.getLedgerVersion()}`);
        console.debug('--------------------------');
      }

      async setLedgerOptions(prepared) {
        return {
          minLedgerVersion: await this.api.getLedgerVersion(),
          maxLedgerVersion: prepared.instructions.maxLedgerVersion
        };
      }
    };
    CODE
  end
end
