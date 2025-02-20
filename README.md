# Ethex

Ethereum Contract interaction via json-rpc for multi-chain based on ex_abi, focused on Smart Contract interaction, with reading contract, writing contract, synchronizing contract events.

**NOTE: version `1.x.x` is incompatible with `0.x.x`**

## Installation

The package can be installed by adding `ethex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ethex, "~> 1.1.0"}
  ]
end
```

## Usage

You can get eth_block_number directly:

```elixir
iex(1)> Ethex.block_number "https://binance.llamarpc.com"
{:ok, 46792582}
```

### Wallet

Create or import wallet by private key, examples below,

```elixir
iex(1)> Ethex.create_wallet
%Ethex.Web3.Wallet{
  private_key: "58d4475ecd42f9be425b28866374741db82dd6b71cfb0eb54bb1a09ff85ca87b",
  public_key: "04d179509d453e1d401850c1dc4ba16541487dd22565747ccde722312802e05c3b4f39375891a711f05aa93f56da130eed164efa10620a9a45390b66046862653b",
  eth_address: "0x2dc3c3ce6901ab9be01379d374d58c1eb0fc7a85",
  mnemonic_phrase: "flee peasant stumble once convince tennis annual govern major brick brown derive lizard twice symbol panda attitude prevent unaware donkey zebra comic peanut lazy"
}

iex(2)> Ethex.create_wallet "58d4475ecd42f9be425b28866374741db82dd6b71cfb0eb54bb1a09ff85ca87b"
%Ethex.Web3.Wallet{
  private_key: "58d4475ecd42f9be425b28866374741db82dd6b71cfb0eb54bb1a09ff85ca87b",
  public_key: "04d179509d453e1d401850c1dc4ba16541487dd22565747ccde722312802e05c3b4f39375891a711f05aa93f56da130eed164efa10620a9a45390b66046862653b",
  eth_address: "0x2dc3c3ce6901ab9be01379d374d58c1eb0fc7a85",
  mnemonic_phrase: "flee peasant stumble once convince tennis annual govern major brick brown derive lizard twice symbol panda attitude prevent unaware donkey zebra comic peanut lazy"
}
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

**Read the Contract**

```elixir
iex(1)> Test.USDT.symbol
{:ok, "USDT"}

iex(3)> Test.USDT.name
{:ok, "Tether USD"}

iex(5)> Test.USDT.decimals
{:ok, 18}

iex(7)> Test.USDT.get_owner
{:ok, "0xf68a4b64162906eff0ff6ae34e2bb1cd42fef62d"}

iex(9)> Test.USDT.balance_of "0x8CcF629e123D83112423c283998443829A291334"
{:ok, 4011000000000000}
```

**Get logs and decode**

By invoking `eth_getLogs` method, it can fetch contract logs from chain with block range.
Then, decode logs to events as result.

```elixir
iex(1)> block_range = %Ethex.Web3.Structs.BlockRange{from_block: 46798863, to_block: 46798863}

iex(2)> {:ok, logs} = Test.USDT.get_logs_and_decode block_range
{:ok,
 [
   %Ethex.Web3.Structs.Event{
     address: "0x55d398326f99059ff775485246999027b3197955",
     block_hash: "0x943b3daa9119d8d4314f816a0f00cd824c9fe73a6d1a3076d16fe1ce91fc173d",
     block_number: 46798863,
     block_timestamp: 1739978103,
     log_index: "0x1c",
     removed: false,
     transaction_hash: "0x2c3795501857b8d6e1ccd00b4132373b25b76ccd399f1719aadbfec8d688c238",
     transaction_index: "0x6",
     returns: [
       %{name: "from", value: "0x47a90a2d92a8367a91efa1906bfc8c1e05bf10c4"},
       %{name: "to", value: "0x2d3b5ca3e5ff50b12cd9d58216abaaa6b3836443"},
       %{name: "value", value: 296241844581231922050}
     ],
     event_name: "Transfer"
   },
   ...
 ]
```

For polling logs, you need to maintaining block range to avoid `excceed max block` error. 

So here is a util for generating block range, it need `latest` or the block number you sync last time. 
The reason why not use `eth_getFilterChanges` is that some chain not implement this method.

NOTE: the max block range in Polygon is 1000, in BSC is 5000.

```elixir
iex(6)> Test.USDT.gen_block_range "latest"
{:ok, 46799328,
 %Ethex.Web3.Structs.BlockRange{from_block: 46799308, to_block: 46799328}}
 
iex(7)> Test.USDT.gen_block_range 46798000
{:ok, 46798800,
 %Ethex.Web3.Structs.BlockRange{from_block: 46798000, to_block: 46798800}}
```

If wanna sync logs automatically, using GenServer with loop, and maintaining block range. Here is an example,

```elixir
defmodule Test.USDT do
  @moduledoc false
  use GenServer

  use Ethex.Abi,
    # rpc: "https://data-seed-prebsc-1-s1.bnbchain.org:8545",
    rpc: "https://binance.llamarpc.com",
    abi_path: "./priv/abi/usdt.abi.json",
    contract_address: "0x55d398326f99059fF775485246999027B3197955"

  @loop_interval 10

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    Process.send_after(self(), :loop, :timer.seconds(@loop_interval))
    {:ok, %{last_sync_block: "latest"}}
  end

  @impl true
  def handle_info(:loop, %{last_sync_block: last_sync_block} = _state) do
    {:ok, cur_sync_block, block_range} = gen_block_range(last_sync_block)
    {:ok, _evts} = get_logs_and_decode(block_range)

    # do some other work, such as save events into database
    # Repo.insert evts

    Process.send_after(self(), :loop, :timer.seconds(@loop_interval))
    {:noreply, %{last_sync_block: cur_sync_block}}
  end
end
```
