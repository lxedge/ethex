# Ethex

Ethereum json-rpc implementation for multi-chain based on ex_abi.

## Cases I met

### case one

In every elixir backend dapp, you need interact with contract on blockchain. And you need to write or copy get_logs logic and decode_event logic again and again.

### case two

Every time I sync logs from chain, firstly decode indexed topic and decode data, then combine them together. What I need is decoding once and never destroy origin structure of logs.

### case three

In my case, the contract can deployed on ETH, or BSC, or Polygon. So I need to switch between multi-chain, not just one global config for json-rpc client.

## Installation

The package can be installed by adding `ethex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ethex, "~> 0.1.1"}
  ]
end
```

## Usage

### Example

#### eth block number

```elixir
iex(1)> Ethex.block_number "https://matic-mumbai.chainstacklabs.com"
{:ok, 30949805}
```

#### create wallet

```elixir
iex(1)> Ethex.create_wallet
%{
  eth_address: "0x13296794f023afd228da924cb55f89df4840bb32",
  mnemonic_phrase: "cream attack thank jewel evolve mansion kitten round rare spice ridge couple emerge pluck farm three vibrant danger curious top unit general suspect agent",
  private_key: "32e1cf7f3bf4e30e9ed5e3b21a32e618948b4d54cf08f366ecd7f27edac1b6b0",
  public_key: "040be14240ba8e85cd9951a275a5cf4d7741883b0b292f98759c75e388abc2ab1068587932015649aa516719bbe147b3b5facdaf210d0903b697e9e47c893e3178"
}
```

#### get logs and decode

```elixir

```
