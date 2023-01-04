defmodule Ethex do
  @moduledoc """
  Documentation for `Ethex`.
  """
  alias Ethex.Account.Wallet
  alias Ethex.Abi.{Abi, Event}

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

  # #### Event related ####

  @spec get_logs_and_decode(String.t(), String.t(), map()) :: {:error, any()} | {:ok, list()}
  defdelegate get_logs_and_decode(rpc, abi_name, filter), to: Event

  @spec decode(list(), [ABI.FunctionSelector.t(), ...]) :: list()
  defdelegate decode(logs, selectors), to: Event

  @spec decode_log(map(), ABI.FunctionSelector.t()) :: map()
  defdelegate decode_log(log, selector), to: Event
end
