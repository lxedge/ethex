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
    {:ethex, "~> 0.1.2"}
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

#### get logs and decode

```elixir
iex(1)> Ethex.register_abi "erc20", "/path/to/erc20.abi.json"
:ok
iex(2)> filter = %{fromBlock: "0x1D841AD", toBlock: "0x1D8434C", address: ["0x42F771DC235830077A04EE518472D88671755fF8"]}
%{
  address: ["0x42F771DC235830077A04EE518472D88671755fF8"],
  fromBlock: "0x1D841AD",
  toBlock: "0x1D8434C"
}
iex(3)> Ethex.get_logs_and_decode "https://matic-mumbai.chainstacklabs.com", "erc20", filter
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

#### gen block range

```elixir
iex(1)> Ethex.gen_block_range "https://matic-mumbai.chainstacklabs.com", "latest"
{:ok, 31246216, %{fromBlock: "0x1DCC774", toBlock: "0x1DCC788"} }
iex(2)> Ethex.gen_block_range "https://matic-mumbai.chainstacklabs.com", 31246216
{:ok, 31246262, %{fromBlock: "0x1DCC788", toBlock: "0x1DCC7B6"} }
```
