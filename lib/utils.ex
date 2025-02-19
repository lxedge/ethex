defmodule Ethex.Utils do
  @moduledoc """
  some utils
  """
  require Logger

  @spec to_hex(integer()) :: String.t()
  def to_hex(number), do: "0x" <> Integer.to_string(number, 16)

  @spec from_hex(String.t()) :: integer()
  def from_hex("0x" <> hex_string), do: String.to_integer(hex_string, 16)

  # @spec camel_to_underscore(map()) :: map()
  # def camel_to_underscore(map) when is_map(map) do
  #   Enum.reduce(map, %{}, fn {k, v}, acc ->
  #     Map.put(acc, k |> Macro.underscore() |> String.to_atom(), v)
  #   end)
  # end
end
