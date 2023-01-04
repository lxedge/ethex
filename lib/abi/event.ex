defmodule Ethex.Abi.Event do
  @moduledoc """
  "https://mainnet.infura.io/v3/{{INFURA_API_KEY}}"

  %{
    address: ["0x497c41e4d95e9738bde7f23977e22d875de8fbd4"],
    fromBlock: "0xF83845",
    toBlock: "0xFA3845"
  }
  """
  alias Ethex.Abi.Abi
  alias Ethex.Utils
  alias Ethex.Query

  @doc """
  combine eth_getLogs with decode, using the given abi_name, which MUST register in Abi genserver.

  NOTE: address in filter SHOULD match abi_name, or will be discard.
  """
  @spec get_logs_and_decode(String.t(), String.t(), map()) :: {:error, any()} | {:ok, list()}
  def get_logs_and_decode(rpc, abi_name, filter) do
    with {:ok, selectors} <- Abi.get_selectors_by_name(abi_name),
         {:ok, logs} <- Query.eth_get_logs(rpc, filter) do
      {:ok, decode(logs, selectors)}
    else
      error -> error
    end
  end

  @doc """
  decode given logs using given function selectors.

  discard log when no function_selector match its method_id.
  """
  @spec decode(list(), [ABI.FunctionSelector.t(), ...]) :: list()
  def decode(logs, selectors) do
    event_selectors = Enum.filter(selectors, &(&1.type == :event))

    Enum.map(logs, fn log ->
      case find_selector(log.topics |> hd(), event_selectors) do
        nil -> nil
        selector -> decode_log(log, selector)
      end
    end)
    |> Enum.reject(&(&1 == nil))
  end

  @spec decode_log(map(), ABI.FunctionSelector.t()) :: map()
  def decode_log(log, selector) do
    returns = Map.merge(decode_topics(log.topics, selector), decode_data(log.data, selector))
    # list all fields for understanding easily, so doesn't use Macro.underscore() here
    %{
      address: log.address,
      block_hash: log.blockHash,
      block_number: Utils.from_hex(log.blockNumber),
      log_index: log.logIndex,
      removed: log.removed,
      transaction_hash: log.transactionHash,
      transaction_index: log.transactionIndex
    }
    |> Map.put(:returns, returns)
    |> Map.put(:event_name, selector.function)
  end

  defp find_selector(sig, selectors) do
    <<method_id::binary-size(4), _::binary>> = to_binary_helper(sig)
    Enum.find(selectors, fn s -> s.method_id == method_id end)
  end

  defp decode_topics(topics, selector) do
    [_ | rest_topics] = topics
    names = filter_helper(selector.inputs_indexed, selector.input_names, true)
    types = filter_helper(selector.inputs_indexed, selector.types, true)

    datas =
      rest_topics
      |> Enum.with_index(fn topic, idx ->
        ABI.decode("(#{get_type(Enum.at(types, idx))})", to_binary_helper(topic))
        |> List.first()
        |> elem(0)
        |> encode16_if_need()
      end)

    Enum.zip(Enum.map(names, &String.to_atom(&1)), datas) |> Enum.into(%{})
  end

  defp decode_data(data, selector) do
    names = filter_helper(selector.inputs_indexed, selector.input_names, false)

    datas =
      selector
      |> encode_data_signature()
      |> ABI.decode(to_binary_helper(data))
      |> Enum.map(&encode16_if_need/1)

    Enum.zip(Enum.map(names, &String.to_atom(&1)), datas) |> Enum.into(%{})
  end

  defp encode_data_signature(function_selector) do
    data_types = filter_helper(function_selector.inputs_indexed, function_selector.types, false)
    types = get_types(data_types) |> Enum.join(",")
    "#{function_selector.function}(#{types})"
  end

  defp to_binary_helper(hex_string) do
    hex_string |> String.slice(2..-1) |> Base.decode16!(case: :lower)
  end

  defp filter_helper(inputs_indexed, target_list, reserve_bool) do
    inputs_indexed
    |> Enum.with_index(fn e, idx -> if e == reserve_bool, do: Enum.at(target_list, idx) end)
    |> Enum.reject(&(&1 == nil))
  end

  defp get_types(types) do
    for type <- types do
      get_type(type)
    end
  end

  defp get_type(nil), do: nil
  defp get_type({:int, size}), do: "int#{size}"
  defp get_type({:uint, size}), do: "uint#{size}"
  defp get_type(:address), do: "address"
  defp get_type(:bool), do: "bool"
  defp get_type({:fixed, element_count, precision}), do: "fixed#{element_count}x#{precision}"
  defp get_type({:ufixed, element_count, precision}), do: "ufixed#{element_count}x#{precision}"
  defp get_type({:bytes, size}), do: "bytes#{size}"
  defp get_type(:function), do: "function"
  defp get_type({:array, type, element_count}), do: "#{get_type(type)}[#{element_count}]"
  defp get_type(:bytes), do: "bytes"
  defp get_type(:string), do: "string"
  defp get_type({:array, type}), do: "#{get_type(type)}[]"

  defp get_type({:tuple, types}) do
    encoded_types = Enum.map(types, &get_type/1)
    "(#{Enum.join(encoded_types, ",")})"
  end

  defp get_type(els), do: raise("Unsupported type: #{inspect(els)}")

  defp encode16_if_need(data) do
    if is_bitstring(data) and not String.valid?(data) do
      "0x" <> Base.encode16(data, case: :lower)
    else
      data
    end
  end
end
