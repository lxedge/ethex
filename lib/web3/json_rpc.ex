defmodule Ethex.Web3.JsonRpc do
  @moduledoc """

  ## Gossip Method
  
  These methods track the head of the chain.
  This is how transactions make their way around the network,
  find their way into blocks, and how clients find out about new blocks.

  ## History Method

  Fetches historical records of every block back to genesis.
  This is like one large append-only file, and includes all block headers,
  block bodies, uncle blocks, and transaction receipts.

  ## State Method

  Methods that report the current state of all the data stored.
  The "state" is like one big shared piece of RAM,
  and includes account balances, contract data, and gas estimations.
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

  @doc """
  Returns an array of all logs matching a given filter object.
  """
  def eth_get_logs(rpc, filter) do
    Utils.http_post(rpc, %{method: "eth_getLogs", params: [filter]})
  end

  @doc """
  Creates a filter object, based on filter options,
  to notify when the state changes (logs).
  To check if the state has changed, call eth_getFilterChanges.

  %{
    address: ["0x4aF359FC3dd065F185739EC2f8F444A746A912f2"],
    fromBlock: "0x16DF136",
    toBlock: "latest"
  }
  """
  def eth_new_filter(rpc, filter) do
    Utils.http_post(rpc, %{method: "eth_newFilter", params: [filter]})
  end

  @doc """
  使用 filter_id 获取自 from 以来的 logs
  """
  def eth_get_filter_logs(rpc, filter_id) do
    Utils.http_post(rpc, %{method: "eth_getFilterLogs", params: [filter_id]})
  end

  @doc """
  Polling method for a filter, which returns an array of logs which occurred since last poll.

  REFERENCE: https://ethereum.stackexchange.com/questions/41129/web3-eth-getfilterchangesweb3-filter-filter-id-throws-filter-not-found
  """
  def eth_get_filter_changes(rpc, filter_id) do
    Utils.http_post(rpc, %{method: "eth_getFilterChanges", params: [filter_id]})
  end

  @doc """
  Returns the number of transactions sent from an address.
  """
  def eth_get_transaction_count(rpc, address, block \\ "pending") do
    case Utils.http_post(rpc, %{method: "eth_getTransactionCount", params: [address, block]}) do
      {:ok, num} -> {:ok, Utils.from_hex(num)}
      error -> error
    end
  end

  @doc """
  Executes a new message call immediately without creating a transaction on the block chain.

  ### Parameters

  1. Object - The transaction call object

  - from: DATA, 20 Bytes - (optional) The address the transaction is sent from.
  - to: DATA, 20 Bytes - The address the transaction is directed to.
  - gas: QUANTITY - (optional) Integer of the gas provided for the transaction execution.
      eth_call consumes zero gas, but this parameter may be needed by some executions.
  - gasPrice: QUANTITY - (optional) Integer of the gasPrice used for each paid gas
  - value: QUANTITY - (optional) Integer of the value sent with this transaction
  - data: DATA - (optional) Hash of the method signature and encoded parameters.
      For details see Ethereum Contract ABI in the Solidity documentation

  2. QUANTITY | TAG - integer block number,
      or the string "latest", "earliest" or "pending",
      see the default block parameter
  """
  def eth_call(rpc, params, block \\ "latest") do
    Utils.http_post(rpc, %{method: "eth_call", params: [params, block]})
  end

  @doc """
  Generates and returns an estimate of how much gas is necessary to allow the
  transaction to complete. The transaction will not be added to the blockchain.
  Note that the estimate may be significantly more than the amount of gas actually
  used by the transaction, for a variety of reasons including EVM mechanics and node performance.
  """
  def eth_estimate_gas(rpc, params) do
    case Utils.http_post(rpc, %{method: "eth_estimateGas", params: [params]}) do
      {:ok, num} -> {:ok, Utils.from_hex(num)}
      error -> error
    end
  end
end
