defmodule Ethex.Abi.Function do
  @moduledoc """
  0xf167FcA5b9FeDf4E8baCAf8547225af93832ed6F

  https://matic-mumbai.chainstacklabs.com
  """
  # alias Ethex.Abi.Abi
  # alias Ethex.Blockchain.StateMethod

  # def call(rpc, abi_name, address, fun_name, args \\ []) do
  #   {:ok, selectors} = Abi.get_selectors_by_name(abi_name)
  #   fs = find_selector(fun_name, selectors)
  #   sig = ABI.FunctionSelector.encode(fs)

  #   data = ABI.encode(sig, args) |> Base.encode16(case: :lower)

  #   StateMethod.eth_call(rpc, %{to: address, data: "0x#{data}"})
  # end

  # def find_selector(fun_name, selectors) do
  #   Enum.find(selectors, fn s -> s.type == :function and s.function == fun_name end)
  # end
end
