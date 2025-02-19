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
