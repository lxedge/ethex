defmodule Ethex.Abi do
  @moduledoc """
  Parse `xxx.abi.json` file into functions.
  """
  alias Ethex.Web3.JsonRpc

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @abi_path opts[:abi_path] || raise("abi_path is required for parsing functions.")
      @contract_address opts[:contract_address] || raise("contract_address is required.")
      @rpc opts[:rpc] || raise("rpc is required to know which endpoint to request.")

      ## Handle Function

      fns =
        @abi_path
        |> File.read!()
        |> Jason.decode!()
        |> ABI.parse_specification()
        |> Enum.filter(fn fs ->
          fs.type == :function and not String.starts_with?(fs.function, "_")
        end)

      for fs <- fns do
        name = Macro.underscore(fs.function)
        args = Macro.generate_arguments(Enum.count(fs.input_names), __MODULE__)

        params =
          Enum.zip(fs.input_names, fs.types)
          |> Enum.map(fn {name, type} -> "#{name}(#{inspect(type)})" end)

        doc = "#{name}\n\nparams: #{Enum.join(params, ", ")}"

        @doc doc
        def unquote(:"#{name}")(unquote_splicing(args)) do
          data = encode_data(unquote(Macro.escape(fs)), unquote(args))
          params = %{to: @contract_address, data: data}

          case JsonRpc.eth_call(@rpc, params) do
            {:ok, result} -> {:ok, decode_result(unquote(Macro.escape(fs)), result)}
            error -> error
          end
        end
      end

      defp encode_data(fs, args) do
        args =
          for {type, arg} <- Enum.zip(fs.types, args),
              into: [],
              do: if(type == :address, do: decode16_address(arg), else: arg)

        encoded_data = ABI.encode(fs, args, :input) |> Base.encode16(case: :lower)
        "0x#{encoded_data}"
      end

      defp decode_result(fs, "0x" <> result) do
        decoded_data = ABI.decode(fs, Base.decode16!(result, case: :lower), :output)

        returns =
          for {type, return} <- Enum.zip(fs.returns, decoded_data),
              into: [],
              do: if(type == :address, do: encode16_address_if_need(return), else: return)

        if Enum.count(returns) == 1 do
          List.first(returns)
        else
          returns
        end
      end

      ## Handle Event

      @spec gen_block_range() :: any()
      def gen_block_range(), do: gen_block_range("latest")

      @doc """
      Generate fromBlock and toBlock params according to current block num

      1. when `last_block` == "latest", fetch from newest back to 20 blocks.
      2. when `cur_block` - `last_block` > 800, fetch from `last_block` forwards 800 blocks.
      3. else, `cur_block` - `last_block` > 800, fetch from `last_block` to cur_block.

      NOTE: the max block range in Polygon is 1000, in BSC is 5000.
      """
      @spec gen_block_range(non_neg_integer() | String.t()) :: any()
      def gen_block_range(last_block) do
        case JsonRpc.eth_block_number(@rpc) do
          {:ok, cur_block} ->
            cond do
              is_integer(last_block) and cur_block - last_block > 800 ->
                {:ok, last_block + 800, %{fromBlock: last_block, toBlock: last_block + 800}}

              is_integer(last_block) ->
                {:ok, cur_block, %{fromBlock: last_block, toBlock: cur_block}}

              # "latest" == last_block ->
              true ->
                {:ok, cur_block, %{fromBlock: cur_block - 20, toBlock: cur_block}}
            end

          error ->
            error
        end
      end

      defp encode16_address_if_need(address) do
        if is_bitstring(address) and not String.valid?(address) do
          "0x" <> Base.encode16(address, case: :lower)
        else
          address
        end
      end

      defp decode16_address("0x" <> address), do: decode16_address(address)

      defp decode16_address(address) do
        Base.decode16!(address, case: :mixed)
      end
    end
  end
end
