defmodule Ethex.Blockchain.GossipMethod do
  @moduledoc """
  These methods track the head of the chain.
  This is how transactions make their way around the network,
  find their way into blocks, and how clients find out about new blocks.
  """
  alias Ethex.Utils

  @doc """
  Returns the number of most recent block.
  """
  @spec eth_block_number(String.t()) :: {:error, any} | {:ok, integer}
  def eth_block_number(rpc) do
    case Utils.http_post(rpc, %{method: "eth_blockNumber", params: []}) do
      {:ok, num} -> {:ok, Utils.from_hex(num)}
      error -> error
    end
  end

  @doc """
  Creates new message call transaction or
  a contract creation for signed transactions.
  """
  def eth_send_raw_transaction(rpc, data) do
    Utils.http_post(rpc, %{method: "eth_sendRawTransaction", params: [data]})
  end
end
