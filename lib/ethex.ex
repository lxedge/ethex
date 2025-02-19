defmodule Ethex do
  @moduledoc """
  Documentation for `Ethex`.
  """
  alias Ethex.Web3.{JsonRpc, Wallet}

  @spec block_number(String.t()) :: {:error, any} | {:ok, integer}
  defdelegate block_number(rpc), to: JsonRpc, as: :eth_block_number

  @spec create_wallet() :: %Wallet{}
  defdelegate create_wallet(), to: Wallet, as: :create

  @spec create_wallet(String.t()) :: %Wallet{}
  defdelegate create_wallet(private_key), to: Wallet, as: :create
end
