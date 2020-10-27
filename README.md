# crystal-ripple-sdk
[![Build Status](https://travis-ci.org/solidum-particles/crystal-ripple-sdk.svg?branch=master)](https://travis-ci.org/solidum-particles/crystal-ripple-sdk)

Client SDK for a rippled,  Can doing about creates accounts, setting multisig, sends payment.
this SDK dependency is [ripple-lib](https://github.com/ripple/ripple-lib), [crystal-nodejs](https://github.com/fukaoi/crystal-nodejs). And no need to install Node.JS, ripple-lib of the npm module, Because of the function of crystal-nodejs. If you want to know crystal-nodejs, read README of crystal-nodejs

The main function as Account, Multisig, Payment has existed, there always run verify function after submit the transaction on ripple network . So is the finallize response that return value of crystal-ripple-sdk 

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     ripple:
       github: solidum-particles/crystal-ripple-sdk
   ```

2. Run `shards install`

## NPM module installation

want to add npm module

1. Add the npm module to `js/package.json`

2. Run `make && make install`

## Audit NPM mobule and JS code

Scan npm module for vulnerability and Perform static analyze of js code for security

1. Run `make secure_check`

## Usage

### Account

#### Set up network(testnet or mainnet)

 Only once call set_network() in an application

```crystal
Ripple.set_network(Ripple::Network::Testnet)

or 

Ripple.set_network(Ripple::Network::Mainnet)
```

Connect to rippled URL("s.altnet.rippletest.net:51233" or "s1.ripple.com:443")in default, But want to change URL

```crystal
Ripple.set_network(Ripple::Network::Testnet, "wss://xxxxxxxxxxxxxxxxxxx")

or 

Ripple.set_network(Ripple::Network::Mainnet, "wss://xxxxxxxxxxxxxxxxxxx")
```


#### Generate an account for mainnet

```crystal
require "ripple"

Ripple.set_network(Ripple::Network::Mainnet)
Ripple::Account.generate_account

# <Ripple::Response::Account:0x7ff4e11e19c0 
# @address="rfCs6UPgyW9QEy7nHijAGUhv4neHggMmx6", 
# @secret="spyJDTDjGJUV9Umd3tF93BzY8RshX" >
```

#### Generate an account for testnet

Can receive payment 1000 XRP from testnet faucet when a created account

```crystal
require "ripple"

Ripple.set_network(Ripple::Network::Testnet)
Ripple::Account.generate_account

# <Ripple::Response::Account:0x7f72ab31a9c0 
# @address="rfu3t8HwXARgwKHBvmi5QANw4ta8khwbMY", 
# @secret="shYtb9yWW8PHvB7oudt1Fw6B9hTvd" >
```

#### Get account info by address

```crystal
require "ripple"

Ripple::Account.get_info("rfu3t8HwXARgwKHBKmi5QANw4ta8khwbMY")

# <Ripple::Response::Account::Info:0x7f0629d4a280 
# @sequence=1.0, 
# @xrpBalance="10000", 
# @ownerCount=0.0, 
# @previousAffectingTransactionID="D281559B5CB4F943E724A6F4576F31798FB5F16BEFA2C3C7D95323504D7B81AC", 
# @previousAffectingTransactionLedgerVersion=19481958.0>
```

### Multisig

#### Create signer list

```crystal
require "ripple"

owner_account = 
{
  address: "rKN412L8bRyG3t6Gb3KasggrjdxgtAcU9g",
  secret:  "shqf5DBf41QE1b3eeBU11KFizVsb4",
}
 
signers = 
[
  {
    address: "r9VQQuGXQRLsQ6CUG2jmwPDr9cGyeczUiY",
    weight:  2,
  },
  {
    address: "r3bJteyQ9VU6gQPn5Ar6nMH9ELjUTY12f",
    weight:  1,
  },
]
 
quorum = 3

Ripple::Multisig.create_signer_list(
  owner_account,
  signers,
  quorum
)
 
# <Ripple::Response::Multisig:0x7f5346fa1dc0 
# @resultCode="tesSUCCESS", 
# @resultMessage="The transaction was applied. Only final in a validated ledger.", 
# .... more values
```

#### Create signer list, Set customize fee

```crystal
require "ripple"

# Can set customize fee
 

owner_account = 
{
  address: "rKN412L8bRyG3t6Gb3KasggrjdxgtAcU9g",
  secret:  "shqf5DBf41QE1b3eeBU11KFizVsb4",
}
 
signers = 
[
  {
    address: "r9VQQuGXQRLsQ6CUG2jmwPDr9cGyeczUiY",
    weight:  2,
  },
  {
    address: "r3bJteyQ9VU6gQPn5Ar6nMH9ELjUTY12f",
    weight:  1,
  },
]
 
quorum = 3

# XRP
fee = "0.000012"

Ripple::Multisig.create_signer_list(
  owner_account,
  signers,
  quorum,
  fee
)
 
# <Ripple::Response::Multisig:0x7f5346fa1dc0 
# @resultCode="tesSUCCESS", 
# @resultMessage="The transaction was applied. Only final in a validated ledger.", 
# .... more values
```

### Payment

#### Send payment

```crystal
require "ripple"

owner_account = 
{
  address: "rKN412L8bRyG3t6Gb3KasggrjdxgtAcU9g",
  secret:  "shqf5DBf41QE1b3eeBU11KFizVsb4",
}

to_address = "raNMGRcQ7McWzXYL7LisGDPH5D5Qrtoprp"

# XRP
amount = "100" 

Ripple::Payment.send(
  owner_account, 
  to_address,
  amount
)
 
# <Ripple::Response::Payment:0x7fe8ce105c80 
# @resultCode="tesSUCCESS", 
# @resultMessage="The transaction was applied. Only final in a validated ledger.",  
# .... more values
```

#### Send payment together with tags, memots

```crystal
require "ripple"

owner_account = 
{
  address: "rKN412L8bRyG3t6Gb3KasggrjdxgtAcU9g",
  secret:  "shqf5DBf41QE1b3eeBU11KFizVsb4",
}

to_address = "raNMGRcQ7McWzXYL7LisGDPH5D5Qrtoprp"

tags = {source: "410084811", destination: "21002010"}

memos = {type: "test", data: "spec demo data", format: "text/plain"}

# XRP
amount = "100" 

Ripple::Payment.send(
  owner_account, 
  to_address,
  amount,
  tags,
  memos
)
 
# <Ripple::Response::Payment:0x7fe8ce105c80 
# @resultCode="tesSUCCESS", 
# @resultMessage="The transaction was applied. Only final in a validated ledger.",  
# .... more values
```

#### Send payment by multisig

Case send payment by multisig, use send_by_multisig method 

```crystal
require "ripple"

owner_account = 
{
  address: "rKN412L8bRyG3t6Gb3KasggrjdxgtAcU9g",
  secret:  "shqf5DBf41QE1b3eeBU11KFizVsb4",
}

to_address = "raNMGRcQ7McWzXYL7LisGDPH5D5Qrtoprp"

signers =
[
  {
    secret:  "snKL7oepViqLduoqtTBygTrZ93CDB",
    address: "rhjH5BdaH4xen4uWQQPH39xMMHgz3N45Hx",
  },
  {
    secret:  "snHdYhJWoxTyVoRchFdgcyKkTK24X",
    address: "rsHbJ4gaxL8GYVDjZmWYixiRXsVHehLJhQ",
  },
]

# XRP
amount = "100" 

Ripple::Payment.send_by_multisig(
  owner_account, 
  to_address,
  amount,
  signers
)
 
# <Ripple::Response::Payment:0x7fe8ce105c80 
# @resultCode="tesSUCCESS", 
# @resultMessage="The transaction was applied. Only final in a validated ledger.",  
# .... more values
```


## Development

#### JS codes

JsClass is defined fat code, common logic code

>source: src/ripple/js_class/*

* Ripple::JsClass::Account  
* Ripple::JsClass::Multisig  
* Ripple::JsClass::Payment  


#### Response types

Be Converted to Ripple::Response class from all responses of ripple-lib

>source: src/ripple/response/*

* Ripple::Response::Account
* Ripple::Response::Memos
* Ripple::Response::Multisig
* Ripple::Response::Payment
* Ripple::Response::Settings
* Ripple::Response::Verify

#### Error types

>source: src/ripple.cr


ResponseError

* Raised exception, If the empty response from ripple-lib

ValidationError

* Raised this exception in two cases,  one it when is returned key "validError"  in JS code, two  it when did validation error in Crystal code 

#### Create address in command line

a wordy command, but you can write with one liner.Changing Mainnet and Testnet is 
 only change of param(Ripple::Network)  in set_network() method

* testnet: 

```crystal
crystal eval 'require "./src/ripple";Ripple.set_network(Ripple::Network::Testnet);p Ripple::Account.generate_account'
```

* mainnet: 

```crystal
crystal eval 'require "./src/ripple";Ripple.set_network(Ripple::Network::Mainnet);p Ripple::Account.generate_account'
```



## Contributing

1. Fork it (<https://github.com/solidum-particles/crystal-ripple-sdk/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [fukaoi](https://github.com/fukaoi) - creator and maintainer
