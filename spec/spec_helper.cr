require "spec"
require "colorize"
require "../src/ripple"

module Helper
  extend self

  @@from_account = {address: "", secret: ""}
  @@to = {address: "", secret: ""}
  @@signers2 = [{address: "", secret: "", weight: 0}]
  @@signers3 = [{address: "", secret: "", weight: 0}]

  def from_account
    if @@from_account[:address].empty?
      @@from_account = generate_account
      disp "--- created: from_account ---"
      disp("#{@@from_account}\n")
    end
    @@from_account
  end

  def to
    if @@to[:address].empty?
      @@to = generate_account
      disp "--- created: to ---"
      disp("#{@@to}\n")
    end
    @@to[:address]
  end

  def to_req_tag
    # @@to = generate_account if @@to[:address].empty?
    # @@to[:address]
  end

  def signers_2
    if @@signers2[0][:address].empty?
      @@signers2 = setup_signers(2)
      disp "--- created: setup_signers ---"
      disp("#{@@signers2}\n")
    end

    Ripple::Multisig.create_signer_list(
      from_account,
      extract_secret(@@signers2),
      2
    )
    extract_weight(@@signers2)
  end

  def signers_3
    if @@signers3[0][:address].empty?
      @@signers3 = setup_signers(3)
      disp "--- created: setup_signers ---"
      disp("#{@@signers3}\n")
    end

    Ripple::Multisig.create_signer_list(
      from_account,
      extract_secret(@@signers3),
      2
    )
    extract_weight(@@signers3)
  end

  def no_regist_signers_2
    signers2
    extract_weight(setup_signers(2))
  end

  def no_appropriate_signers_2
    signers2 = setup_signers(2)
    disp("#{signers2}\n")

    Ripple::Multisig.create_signer_list(
      generate_account, # no much address
      extract_secret(signers2),
      2
    )
    extract_weight(signers2)
  end

  def generate_account
    account = Ripple::Account.generate_account
    {address: account.address.to_s, secret: account.secret.to_s}
  end

  def setup_signers(count)
    accounts = [] of NamedTuple(
      address: String,
      secret: String,
      weight: Int32)

    count.times do
      account = generate_account
      format = {
        address: account[:address],
        secret:  account[:secret],
        weight:  1,
      }
      accounts.push(format)
    end
    accounts
  end

  def extract_secret(signer_accounts : Array)
    signer_accounts.map do |account|
      {
        address: account[:address],
        weight:  account[:weight],
      }
    end
  end

  def extract_weight(signer_accounts : Array)
    signer_accounts.map do |account|
      {
        address: account[:address],
        secret:  account[:secret],
      }
    end
  end

  def disp(mess)
    puts mess.colorize.green
  end

  def get_balance(address : String) : Float64
    Ripple::Account.get_info(address).xrpBalance.to_f
  end
end
