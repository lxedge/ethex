defmodule Ethex.Abi.Function do
  @moduledoc """
  0xf167FcA5b9FeDf4E8baCAf8547225af93832ed6F

  https://matic-mumbai.chainstacklabs.com

  Ethex.call "https://matic-mumbai.chainstacklabs.com",
    "erc20", "0xf167FcA5b9FeDf4E8baCAf8547225af93832ed6F", "symbol"

  Ethex.call "https://matic-mumbai.chainstacklabs.com",
    "erc20", "0xf167FcA5b9FeDf4E8baCAf8547225af93832ed6F", "balanceOf",
    ["8CcF629e123D83112423c283998443829A291334" |> Base.decode16!(case: :mixed)]
  """
  alias Ethex.Abi.Abi
  alias Ethex.Blockchain.StateMethod

  @doc """
  call contract function

  NOTE: address SHOULD BE binary
  """
  @spec call(String.t(), String.t(), String.t(), String.t(), list()) ::
          {:ok, list()} | {:error, any()}
  def call(rpc, abi_name, address, fun_name, args \\ []) do
    with {:ok, selectors} <- Abi.get_selectors_by_name(abi_name),
         fs <- find_selector(fun_name, selectors),
         {:ok, "0x" <> returns} <-
           StateMethod.eth_call(rpc, %{
             to: address,
             data: "0x#{Base.encode16(ABI.encode(fs, args, :input), case: :lower)}"
           }) do
      {:ok, ABI.decode(fs, Base.decode16!(returns, case: :lower), :output)}
    else
      {:error, :not_found} -> {:error, :abi_not_register}
      nil -> {:error, :function_selector_not_found}
      error -> error
    end
  end

  defp find_selector(fun_name, selectors) do
    Enum.find(selectors, fn s -> s.type == :function and s.function == fun_name end)
  end
end
