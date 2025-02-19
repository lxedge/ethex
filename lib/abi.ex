defmodule Ethex.Abi do
  @moduledoc """
  Parse `xxx.abi.json` file into functions.
  """
  alias Ethex.Blockchain.StateMethod

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @abi_path opts[:abi_path] || raise("abi_path is required for parsing functions.")
      @contract_address opts[:contract_address] || raise("contract_address is required.")
      @rpc opts[:rpc] || raise("rpc is required to know which endpoint to request.")

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

        def unquote(:"#{name}")(unquote_splicing(args)) do
          data = encode_data(unquote(Macro.escape(fs)), unquote(args))
          params = %{to: @contract_address, data: data}

          case StateMethod.eth_call(@rpc, params) do
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
