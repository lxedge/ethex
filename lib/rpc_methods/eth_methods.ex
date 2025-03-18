defmodule Ethex.RpcMethods.EthMethods do
  @moduledoc """
  Methods not implement

  1. eth_sign
  2. eth_signTransaction
  3. eth_sendTransaction
  4. eth_compileSolidity
  5. eth_compileLLL
  6. eth_compileSerpent
  7. eth_newPendingTransactionFilter
  8. eth_submitHashrate
  9. eth_pendingTransactions
  10. eth_requestAccounts
  """
  alias Ethex.Utils.Rpc

  @doc """
  Returns an object with the sync status of the node if the node is out-of-sync and is syncing.
  Returns false when the node is already in sync. 
  """
  def get_syncing(rpc) do
    Rpc.http_post(rpc, %{method: "eth_syncing", params: []})
  end

  @doc """
  Returns the client coinbase address.  The coinbase address is the account to pay mining rewards to.
  """
  def get_coinbase(rpc) do
    Rpc.http_post(rpc, %{method: "eth_coinbase", params: []})
  end

  @doc """
  Returns true if client is actively mining new blocks.
  """
  def get_mining(rpc) do
    Rpc.http_post(rpc, %{method: "eth_mining", params: []})
  end

  @doc """
  Returns the number of hashes per second that the node is mining with.
  Only applicable when the node is mining.
  """
  def get_hash_rate(rpc) do
    Rpc.http_post(rpc, %{method: "eth_hashrate", params: []})
  end

  @doc """
  Returns the current gas price in wei.
  """
  def get_gas_price(rpc) do
    Rpc.http_post(rpc, %{method: "eth_gasPrice", params: []})
  end

  @doc """
  Returns an estimate of how much priority fee, in wei, you need to be included in a block.
  """
  def get_max_priority_fee_per_gas(rpc) do
    Rpc.http_post(rpc, %{method: "eth_maxPriorityFeePerGas", params: []})
  end

  @doc """
  Returns a list of addresses owned by the client.
  """
  def get_accounts(rpc) do
    Rpc.http_post(rpc, %{method: "eth_accounts", params: []})
  end

  @doc """
  Returns the latest block number of the blockchain.
  """
  def get_block_number(rpc) do
    Rpc.http_post(rpc, %{method: "eth_blockNumber", params: []})
  end

  @doc """
  Returns the balance of the account of a given address.
  """
  def get_balance(rpc, address, block_number) do
    Rpc.http_post(rpc, %{method: "eth_getBalance", params: [address, block_number]})
  end

  @doc """
  Returns the value from a storage position at a given address.
  """
  def get_storage_at(rpc, address, storage_slot, block_number) do
    Rpc.http_post(rpc, %{
      method: "eth_getStorageAt",
      params: [address, storage_slot, block_number]
    })
  end

  @doc """
  Returns the number of transactions sent from an address.
  """
  def get_transaction_count(rpc, address, block_number) do
    Rpc.http_post(rpc, %{method: "eth_getTransactionCount", params: [address, block_number]})
  end

  @doc """
  Returns the number of transactions in the block with the given block hash.
  """
  def get_block_transaction_count_by_hash(rpc, block_hash) do
    Rpc.http_post(rpc, %{method: "eth_getBlockTransactionCountByHash", params: [block_hash]})
  end

  @doc """
  Returns the number of transactions in the block with the given block hash.
  """
  def get_block_transaction_count_by_number(rpc, block_number) do
    Rpc.http_post(rpc, %{method: "eth_getBlockTransactionCountByNumber", params: [block_number]})
  end

  @doc """
  Returns the number of uncles in a block from a block matching the given block hash.
  """
  def get_uncle_count_by_block_hash(rpc, block_hash) do
    Rpc.http_post(rpc, %{method: "eth_getUncleCountByBlockHash", params: [block_hash]})
  end

  @doc """
  Returns the number of uncles in a block from a block matching the given block number.
  """
  def get_uncle_count_by_block_number(rpc, block_number) do
    Rpc.http_post(rpc, %{method: "eth_getUncleCountByBlockNumber", params: [block_number]})
  end

  @doc """
  Returns the compiled byte code of a smart contract, if any, at a given address.
  """
  def get_code(rpc, address, block_number) do
    Rpc.http_post(rpc, %{method: "eth_getCode", params: [address, block_number]})
  end

  @doc """
  Submits a pre-signed transaction for broadcast to the Ethereum network.
  """
  def send_raw_transaction(rpc, transaction) do
    Rpc.http_post(rpc, %{method: "eth_sendRawTransaction", params: [transaction]})
  end

  @doc """
  Executes a new message call immediately without creating a transaction on the blockchain.
  """
  def call(rpc, transaction, block_number) do
    Rpc.http_post(rpc, %{method: "eth_call", params: [transaction, block_number]})
  end

  @doc """
  Generates and returns an estimate of how much gas is necessary to allow the transaction to complete.
  The transaction will not be added to the blockchain.

  Note that the estimate may be significantly more than the amount of gas actually used by the transaction,
  for a variety of reasons including EVM mechanics and node performance.
  """
  def estimate_gas(rpc, transaction, block_number) do
    Rpc.http_post(rpc, %{method: "eth_estimateGas", params: [transaction, block_number]})
  end

  @doc """
  Returns information about a block whose hash is in the request.

  ### Parameters

  - hash: (string) [Required] A string representing the hash (32 bytes) of a block.
  - transaction details flag: (boolean) [Required]
    If set to true, returns the full transaction objects,
    if false returns only the hashes of the transactions.
  """
  def get_block_by_hash(rpc, block_hash, hydrated) do
    Rpc.http_post(rpc, %{method: "eth_getBlockByHash", params: [block_hash, hydrated]})
  end

  @doc """
  Returns information of the block matching the given block number.
  """
  def get_block_by_number(rpc, block_number, hydrated) do
    Rpc.http_post(rpc, %{method: "eth_getBlockByNumber", params: [block_number, hydrated]})
  end

  @doc """
  Returns information about a transaction for a given hash.
  """
  def get_transaction_by_hash(rpc, transaction_hash) do
    Rpc.http_post(rpc, %{method: "eth_getTransactionByHash", params: [transaction_hash]})
  end

  @doc """
  Returns information about a transaction given block hash and transaction index position.
  """
  def get_transaction_by_block_hash_and_index(rpc, block_hash, transaction_index) do
    Rpc.http_post(rpc, %{
      method: "eth_getTransactionByBlockHashAndIndex",
      params: [block_hash, transaction_index]
    })
  end

  @doc """
  Returns information about a transaction given block number and transaction index position.
  """
  def get_transaction_by_block_number_and_index(rpc, block_number, transaction_index) do
    Rpc.http_post(rpc, %{
      method: "eth_getTransactionByBlockHashAndIndex",
      params: [block_number, transaction_index]
    })
  end

  @doc """
  Returns the receipt of a transaction given transaction hash.
  Note that the receipt is not available for pending transactions.
  """
  def get_transaction_receipt(rpc, transaction_hash) do
    Rpc.http_post(rpc, %{method: "eth_getTransactionReceipt", params: [transaction_hash]})
  end

  @doc """
  Returns information about an uncle of a block given the block hash and the uncle index position.
  """
  def get_uncle_by_block_hash_and_index(rpc, block_hash, uncle_index) do
    Rpc.http_post(rpc, %{
      method: "eth_getUncleByBlockHashAndIndex",
      params: [block_hash, uncle_index]
    })
  end

  @doc """
  Returns information about an uncle of a block given the block number and the uncle index position.
  """
  def get_uncle_by_block_number_and_index(rpc, block_number, uncle_index) do
    Rpc.http_post(rpc, %{
      method: "eth_getUncleByBlockNumberAndIndex",
      params: [block_number, uncle_index]
    })
  end

  @doc """
  Returns a list of available compilers in the client
  """
  def get_compilers(rpc) do
    Rpc.http_post(rpc, %{method: "eth_getCompilers", params: []})
  end

  @doc """
  Creates a filter object, based on filter options, to notify when the state changes (logs).
  To check if the state has changed, call eth_getFilterChanges.
  """
  def new_filter(rpc, filter) do
    Rpc.http_post(rpc, %{method: "eth_newFilter", params: [filter]})
  end

  @doc """
  Creates a filter in the node, to notify when a new block arrives.
  To check if the state has changed, call eth_getFilterChanges.
  """
  def new_block_filter(rpc) do
    Rpc.http_post(rpc, %{method: "eth_newBlockFilter", params: []})
  end

  @doc """
  It uninstalls a filter with the given filter id.
  """
  def uninstall_filter(rpc, filter_id) do
    Rpc.http_post(rpc, %{method: "eth_uninstallFilter", params: [filter_id]})
  end

  @doc """
  Polling method for a filter, which returns an array of events that have occurred since the last poll.
  """
  def get_filter_changes(rpc, filter_id) do
    Rpc.http_post(rpc, %{method: "eth_getFilterChanges", params: [filter_id]})
  end

  @doc """
  Returns an array of all logs matching filter with given id.
  """
  def get_filter_logs(rpc, filter_id) do
    Rpc.http_post(rpc, %{method: "eth_getFilterLogs", params: [filter_id]})
  end

  @doc """
  Returns an array of all the logs matching the given filter object.
  """
  def get_logs(rpc, filter) do
    Rpc.http_post(rpc, %{method: "eth_getLogs", params: [filter]})
  end

  @doc """
  Returns the hash of the current block, the seed hash, and the boundary condition to be met ("target").
  """
  def get_work(rpc) do
    Rpc.http_post(rpc, %{method: "eth_getWork", params: []})
  end

  @doc """
  Used for submitting a proof-of-work solution.
  """
  def submit_work(rpc, nonce, hash, digest) do
    Rpc.http_post(rpc, %{method: "eth_submitWork", params: [nonce, hash, digest]})
  end

  @doc """
  Returns historical gas information, allowing you to track trends over time.

  https://docs.metamask.io/services/reference/ethereum/json-rpc-methods/eth_feehistory/
  """
  def get_fee_history(rpc, block_count, newest_block, reward_percentiles) do
    Rpc.http_post(rpc, %{
      method: "eth_feeHistory",
      params: [block_count, newest_block, reward_percentiles]
    })
  end

  @doc """
  Returns the currently configured chain ID, a value used in replay-protected transaction signing as introduced by EIP-155.
  """
  def get_chain_id(rpc) do
    Rpc.http_post(rpc, %{method: "eth_chainId", params: []})
  end

  @doc """
  Returns the account and storage values, including the Merkle proof, of the specified account.
  """
  def get_proof(rpc, address, storage_keys, block_number) do
    Rpc.http_post(rpc, %{method: "eth_getProof", params: [address, storage_keys, block_number]})
  end

  @doc """
  Returns the current client version.
  """
  def get_node_info(rpc) do
    Rpc.http_post(rpc, %{method: "web3_clientVersion", params: []})
  end

  @doc """
  Creates an EIP-2930 access list that you can include in a transaction.
  """
  def create_access_list(rpc, transaction, block_number) do
    Rpc.http_post(rpc, %{method: "eth_createAccessList", params: [transaction, block_number]})
  end
end
