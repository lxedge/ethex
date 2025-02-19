# Ethex

Ethereum json-rpc implementation for multi-chain based on ex_abi.

## Cases I met

### case one

In every elixir backend dapp, you need interact with contract on blockchain. And you need to write or copy get_logs logic and decode_event logic again and again.

### case two

Every time I sync logs from chain, firstly decode indexed topic and decode data, then combine them together. What I need is decoding once and never destroy origin structure of logs.

### case three

In my case, the contract can deployed on ETH, or BSC, or Polygon. So I need to switch between multi-chain, not just one global config for json-rpc client.

### case four

In production, there are many contracts which its address is constructed by a factory contract. So those library who combine address in a module is not a good idea.

## Installation

The package can be installed by adding `ethex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ethex, "~> 0.1.3"}
  ]
end
```

## Usage

You can get eth_block_number directly:

```elixir
iex(1)> Ethex.block_number "https://binance.llamarpc.com"
{:ok, 46792582}
```

### Interact with contract

First write a module to parse abi, known which contract address interact with and rpc endpoint request to.

```elixir
defmodule Test.USDT do
  @moduledoc false
  use Ethex.Abi,
    rpc: "https://binance.llamarpc.com",
    abi_path: "./priv/abi/usdt.abi.json",
    contract_address: "0x55d398326f99059fF775485246999027B3197955"
end
```

Then you can call functions:

```elixir
iex(1)> Test.USDT.symbol
{:ok, "USDT"}
iex(2)>
iex(3)> Test.USDT.name
{:ok, "Tether USD"}
iex(4)>
iex(5)> Test.USDT.decimals
{:ok, 18}
iex(6)>
iex(7)> Test.USDT.get_owner
{:ok, "0xf68a4b64162906eff0ff6ae34e2bb1cd42fef62d"}
iex(8)>
iex(9)> Test.USDT.balance_of "0x8CcF629e123D83112423c283998443829A291334"
{:ok, 4011000000000000}
```

And when do sync logs from blockchain by https endpoint:

```elixir
iex(4)> filter = %{fromBlock: "0x1D841AD", toBlock: "0x1D8434C", address: ["0x42F771DC235830077A04EE518472D88671755fF8"]}
%{
  address: ["0x42F771DC235830077A04EE518472D88671755fF8"],
  fromBlock: "0x1D841AD",
  toBlock: "0x1D8434C"
}
iex(5)> Ethex.get_logs_and_decode "https://matic-mumbai.chainstacklabs.com", "erc20", filter
{:ok,
 [
   %Ethex.Struct.Transaction{
     address: "0x42f771dc235830077a04ee518472d88671755ff8",
     block_hash: "0xcc827e8fae4271bf91c65ce10b3a590b6d9c2d665cf8ae55224caf1444753b9d",
     block_number: 30950172,
     event_name: "Transfer",
     log_index: "0x10",
     removed: false,
     returns: [
       %{name: "_from", value: "0x8ccf629e123d83112423c283998443829a291334"},
       %{name: "_to", value: "0xa2e7d1addb682c3f2ba78d5124433cb8ba2a4f4b"},
       %{name: "_value", value: 10000000000000000000000}
     ],
     transaction_hash: "0x48965d02c69f3eae46486d677efd55f06943fda3d8c2acf667ac5980ad569a1c",
     transaction_index: "0x5"
   }
 ]}
```

For polling logs, you need to maintaining rpc endpoint and block range, to avoid `excceed max block` error. So here is a util for generate block range, it need `latest` or the block number you sync last time. The reason why not use `eth_getFilterChanges` is that some chain not implement this method.

```elixir
iex(1)> Ethex.gen_block_range "https://matic-mumbai.chainstacklabs.com", "latest"
{:ok, 31246216, %{fromBlock: "0x1DCC774", toBlock: "0x1DCC788"} }
iex(2)> Ethex.gen_block_range "https://matic-mumbai.chainstacklabs.com", 31246216
{:ok, 31246262, %{fromBlock: "0x1DCC788", toBlock: "0x1DCC7B6"} }
```
