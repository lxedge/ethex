defmodule Ethex.Blockchain.HistoryMethod do
  @moduledoc """
  Fetches historical records of every block back to genesis.
  This is like one large append-only file, and includes all block headers,
  block bodies, uncle blocks, and transaction receipts.
  """
  alias Ethex.Utils

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
end
