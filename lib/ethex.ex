defmodule Ethex do
  @moduledoc """
  Documentation for `Ethex`.
  """
  alias Ethex.Account.Wallet
  alias Ethex.Abi.{Abi, Function, Event}
  alias Ethex.Blockchain.{GossipMethod}

  # #### Blockchain related ####

  @spec block_number(String.t()) :: {:error, any} | {:ok, integer}
  defdelegate block_number(rpc), to: GossipMethod, as: :eth_block_number

  # #### Account related ####

  @spec create_wallet :: map()
  defdelegate create_wallet(), to: Wallet, as: :create

  @spec create_wallet(String.t()) :: map()
  defdelegate create_wallet(private_key), to: Wallet, as: :create

  # #### Abi related ####

  @spec register_abi(String.t(), any) :: :ok | :error
  defdelegate register_abi(name, abi_file_path), to: Abi

  @spec get_selectors_by_name(String.t()) :: {:ok, list()} | {:error, :not_found}
  defdelegate get_selectors_by_name(name), to: Abi

  # #### Function related ####

  @spec call(String.t(), String.t(), String.t(), String.t(), list()) ::
          {:ok, list()} | {:error, any()}
  defdelegate call(rpc, abi_name, address, fun_name, args \\ []), to: Function

  # #### Event related ####

  @spec gen_block_range(String.t(), non_neg_integer() | String.t()) ::
          {:ok, non_neg_integer(), map()} | {:error, any()}
  defdelegate gen_block_range(rpc, last_block), to: Event

  @spec get_logs_and_decode(String.t(), String.t(), map()) :: {:error, any()} | {:ok, list()}
  defdelegate get_logs_and_decode(rpc, abi_name, filter), to: Event

  @spec decode(list(), [ABI.FunctionSelector.t(), ...]) :: list()
  defdelegate decode(logs, selectors), to: Event

  @spec decode_log(map(), ABI.FunctionSelector.t()) :: map()
  defdelegate decode_log(log, selector), to: Event
end
