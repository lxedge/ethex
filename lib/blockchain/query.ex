defmodule Ethex.Blockchain.Query do
  @moduledoc """
  https://ethereum.org/en/developers/docs/apis/json-rpc/
  """
  require Logger
  alias Ethex.Utils

  @doc """
  当前块号
  """
  @spec eth_block_number(String.t()) :: {:error, any} | {:ok, integer}
  def eth_block_number(rpc) do
    case Utils.http_post(rpc, %{method: "eth_blockNumber", params: []}) do
      {:ok, num} -> {:ok, Utils.from_hex(num)}
      error -> error
    end
  end

  @doc """
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
    Logger.info(name: :eth_call, rpc: rpc, params: inspect(params))
    Utils.http_post(rpc, %{method: "eth_call", params: [params, block]})
  end

  @doc """
  获取历史块的事件，指定块的范围
  """
  def eth_get_logs(rpc, filter) do
    Logger.info(name: :eth_get_logs, rpc: rpc, params: inspect(filter))
    Utils.http_post(rpc, %{method: "eth_getLogs", params: [filter]})
  end

  @doc """
  获取准实时的事件，不需要指定块的范围，增量获取
  如何维护好 filter_id

  %{
    address: ["0x4aF359FC3dd065F185739EC2f8F444A746A912f2"],
    fromBlock: "0x16DF136",
    toBlock: "latest"
  }
  """
  def eth_new_filter(rpc, filter) do
    Logger.info(name: :eth_new_filter, rpc: rpc, params: inspect(filter))
    Utils.http_post(rpc, %{method: "eth_newFilter", params: [filter]})
  end

  @doc """
  使用 filter_id 获取自 from 以来的 logs
  """
  def eth_get_filter_logs(rpc, filter_id) do
    Logger.info(name: :eth_get_filter_logs, rpc: rpc, params: inspect(filter_id))
    Utils.http_post(rpc, %{method: "eth_getFilterLogs", params: [filter_id]})
  end

  @doc """
  使用 filter_id 获取自上次请求的 logs

  filter_id 是薛定谔的id，可能在 not found 后，下一次又可以获取到
  目前推测其可能是在不同节点中，该请求被分配给一个已经 uninstall 的节点
  uninstall 可能是因为这个节点掉线等原因
  下次又分配给了一个没有卸载的节点，这一切的发生，没有任何通知

  能做的仅仅是发现了`filter not found`就重新生成一次，并使用 getLogs 向前抓几个可能丢失的信息

  REFERENCE: https://ethereum.stackexchange.com/questions/41129/web3-eth-getfilterchangesweb3-filter-filter-id-throws-filter-not-found
  """
  def eth_get_filter_changes(rpc, filter_id) do
    Utils.http_post(rpc, %{method: "eth_getFilterChanges", params: [filter_id]})
  end
end
