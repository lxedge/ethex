defmodule Ethex.Blockchain.StateMethod do
  @moduledoc """
  Methods that report the current state of all the data stored.
  The "state" is like one big shared piece of RAM,
  and includes account balances, contract data, and gas estimations.
  """
  alias Ethex.Utils

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
