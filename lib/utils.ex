defmodule Ethex.Utils do
  @moduledoc "Utils"

  @doc """
  To hex

  ## Example

    iex> Ethex.Utils.to_hex 10086
    "0x2766"
  """
  @spec to_hex(integer()) :: String.t()
  def to_hex(number) when is_integer(number), do: "0x" <> Integer.to_string(number, 16)

  @doc """
  From hex

  ## Example

    iex> Ethex.Utils.from_hex "0x2766"
    10086
  """
  @spec from_hex(String.t()) :: integer()
  def from_hex("0x" <> hex_string), do: String.to_integer(hex_string, 16)

  # @spec camel_to_underscore(map()) :: map()
  # def camel_to_underscore(map) when is_map(map) do
  #   Enum.reduce(map, %{}, fn {k, v}, acc ->
  #     Map.put(acc, k |> Macro.underscore() |> String.to_atom(), v)
  #   end)
  # end

  @doc """
  Convert wei to eth.

  ## Example

    iex> Ethex.Utils.from_wei(4011000000000000, 18)
    0.004011
  """
  @spec from_wei(integer(), pos_integer()) :: float()
  def from_wei(number, decimals) when is_integer(number) and is_integer(decimals) do
    number / trunc(:math.pow(10, decimals))
  end

  @doc """
  Convert eth to wei.

  ## Example

    iex> Ethex.Utils.to_wei(0.1, 18)
    100000000000000000
  """
  @spec to_wei(number(), pos_integer()) :: integer()
  def to_wei(number, decimals) when is_integer(decimals) do
    trunc(number * trunc(:math.pow(10, decimals)))
  end
end
