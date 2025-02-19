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
  require Logger
  alias Ethex.Utils

  @doc """
  Returns the number of most recent block.
  """
  @spec eth_block_number(String.t()) :: {:error, any} | {:ok, integer}
  def eth_block_number(rpc) do
    case http_post(rpc, %{method: "eth_blockNumber", params: []}) do
      {:ok, num} -> {:ok, Utils.from_hex(num)}
      error -> error
    end
  end

  @doc """
  Creates new message call transaction or
  a contract creation for signed transactions.
  """
  def eth_send_raw_transaction(rpc, data) do
    http_post(rpc, %{method: "eth_sendRawTransaction", params: [data]})
  end

  @doc """
  Returns an array of all logs matching a given filter object.
  """
  def eth_get_logs(rpc, filter) do
    http_post(rpc, %{method: "eth_getLogs", params: [filter]})
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
    http_post(rpc, %{method: "eth_newFilter", params: [filter]})
  end

  @doc """
  使用 filter_id 获取自 from 以来的 logs
  """
  def eth_get_filter_logs(rpc, filter_id) do
    http_post(rpc, %{method: "eth_getFilterLogs", params: [filter_id]})
  end

  @doc """
  Polling method for a filter, which returns an array of logs which occurred since last poll.

  REFERENCE: https://ethereum.stackexchange.com/questions/41129/web3-eth-getfilterchangesweb3-filter-filter-id-throws-filter-not-found
  """
  def eth_get_filter_changes(rpc, filter_id) do
    http_post(rpc, %{method: "eth_getFilterChanges", params: [filter_id]})
  end

  @doc """
  Returns the number of transactions sent from an address.
  """
  def eth_get_transaction_count(rpc, address, block \\ "pending") do
    case http_post(rpc, %{method: "eth_getTransactionCount", params: [address, block]}) do
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
    http_post(rpc, %{method: "eth_call", params: [params, block]})
  end

  @doc """
  Generates and returns an estimate of how much gas is necessary to allow the
  transaction to complete. The transaction will not be added to the blockchain.
  Note that the estimate may be significantly more than the amount of gas actually
  used by the transaction, for a variety of reasons including EVM mechanics and node performance.
  """
  def eth_estimate_gas(rpc, params) do
    case http_post(rpc, %{method: "eth_estimateGas", params: [params]}) do
      {:ok, num} -> {:ok, Utils.from_hex(num)}
      error -> error
    end
  end

  defp http_post(rpc, params) do
    headers = [{"Content-Type", "application/json"}]
    body = Map.merge(%{jsonrpc: "2.0", id: fetch_request_id()}, params)
    opts = [request_timeout: 30_000, receive_timeout: 5_000]

    with {:ok, body_str} <- Jason.encode(body),
         %Finch.Request{} = req <- Finch.build(:post, rpc, headers, body_str, opts),
         {:ok, %Finch.Response{status: 200, body: body}} <- Finch.request(req, Ethex.Finch),
         {:ok, %{result: result}} <- Jason.decode(body, keys: :atoms) do
      {:ok, result}
    else
      {:error, %Jason.EncodeError{}} ->
        Logger.error("Ethex.Utils.http_post request body error: #{inspect(params)}")
        {:error, :invalid_params}

      {:error, %Mint.TransportError{reason: :nxdomain}} ->
        Logger.error("Ethex.Utils.http_post network error: nxdomain")
        {:error, :network_error}

      {_, %Finch.Response{status: status}} ->
        Logger.error("Ethex.Utils.http_post response status error: #{status}")
        {:error, :response_error}

      {:error, %Jason.DecodeError{}} ->
        Logger.error("Ethex.Utils.http_post response body error")
        {:error, :response_error}

      {:ok, %{error: %{code: errcode, message: errmsg}}} ->
        Logger.error("Ethex.Utils.http_post response error: #{errcode}, #{errmsg}")
        {:error, :"rpc_error_#{errcode}"}

      other ->
        Logger.error("Ethex.Utils.http_post unknown error: #{inspect(other)}")
        {:error, :unknown_error}
    end
  end

  defp fetch_request_id() do
    case Application.fetch_env(:ethex, :request_id) do
      {:ok, value} -> value
      :error -> "ethex"
    end
  end
end
