defmodule Ethex.Accounts.Transactions.EIP1559 do
  @moduledoc """
  Transaction EIP-1559
  https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1559.md
  """

  @type t :: %__MODULE__{
          chain_id: non_neg_integer(),
          nonce: non_neg_integer(),
          max_priority_fee_per_gas: non_neg_integer(),
          max_fee_per_gas: non_neg_integer(),
          gas_limit: non_neg_integer(),
          to: binary(),
          value: non_neg_integer(),
          data: binary(),
          access_list: list()
        }

  # @enforce_keys [:nonce, :gas_limit, :value, :data]
  defstruct chain_id: 0,
            nonce: 0,
            max_priority_fee_per_gas: 0,
            max_fee_per_gas: 0,
            gas_limit: 0,
            to: 0,
            value: 0,
            data: "",
            access_list: []

  def new(tx_attrs) do
    %__MODULE__{
      chain_id: tx_attrs.chain_id,
      nonce: tx_attrs.nonce,
      max_priority_fee_per_gas: tx_attrs.max_priority_fee_per_gas,
      max_fee_per_gas: tx_attrs.max_fee_per_gas,
      gas_limit: tx_attrs.gas_limit,
      to: tx_attrs.to,
      value: tx_attrs.value,
      data: tx_attrs.data,
      access_list: []
    }
  end

  def new_default() do
    %{
      chain_id: 1,
      nonce: 1,
      max_priority_fee_per_gas: 2_000_000_000,
      max_fee_per_gas: 30_000_000_000,
      gas_limit: 21000,
      to: "0x2dc3c3ce6901ab9be01379d374d58c1eb0fc7a85",
      value: 1_000_000_000_000_000_000,
      data: "0x"
    }
    |> new()
  end

  def sign(%__MODULE__{} = tx, private_key) do
    message = get_message_to_sign(tx)
    {r, s, v} = ecsign(message, private_key)

    [
      tx.chain_id,
      tx.nonce,
      tx.max_priority_fee_per_gas,
      tx.max_fee_per_gas,
      tx.gas_limit,
      tx.to,
      tx.value,
      tx.data,
      tx.access_list,
      v,
      r,
      s
    ]
    |> ExRLP.encode(encoding: :hex)
  end

  def ecsign(msg_hash, private_key, chain_id \\ 1) do
    {:ok, {signature, recovery}} = ExSecp256k1.sign_compact(msg_hash, private_key)
    <<r::binary-size(32), s::binary-size(32)>> = signature
    v = if chain_id == 0, do: recovery + 27, else: recovery + (chain_id * 2 + 35)
    {r, s, v}
  end

  def get_message_to_sign(%__MODULE__{} = tx, hash_message? \\ true) do
    message =
      [
        tx.chain_id,
        tx.nonce,
        tx.max_priority_fee_per_gas,
        tx.max_fee_per_gas,
        tx.gas_limit,
        tx.to,
        tx.value,
        tx.data,
        tx.access_list
      ]
      |> ExRLP.encode()

    if hash_message? do
      ExKeccak.hash_256(message)
    else
      message
    end
  end
end
