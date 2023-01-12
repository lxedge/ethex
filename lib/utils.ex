defmodule Ethex.Utils do
  @moduledoc """
  some utils
  """
  require Logger

  @spec to_hex(integer()) :: String.t()
  def to_hex(number), do: "0x" <> Integer.to_string(number, 16)

  @spec from_hex(String.t()) :: integer()
  def from_hex("0x" <> hex_string), do: String.to_integer(hex_string, 16)

  @doc false
  @spec http_post(String.t(), map()) :: any()
  def http_post(rpc, params) do
    headers = [{"content-type", "application/json"}]
    options = [timeout: 60000, recv_timeout: 5000]
    req_body = Map.merge(%{jsonrpc: "2.0", id: fetch_request_id()}, params)

    with {:ok, encoded_data} <- Jason.encode(req_body),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.post(rpc, encoded_data, headers, options),
         {:ok, %{result: result}} <- Jason.decode(body, keys: :atoms) do
      {:ok, result}
    else
      {:ok, %HTTPoison.Response{status_code: 502}} ->
        Logger.error(
          name: :http_post,
          rpc: rpc,
          params: inspect(params),
          error: "Bad Gateway"
        )

      {:ok, %HTTPoison.Response{status_code: 503}} ->
        Logger.error(
          name: :http_post,
          rpc: rpc,
          params: inspect(params),
          error: "Service Temporarily Unavailable"
        )

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error(name: :http_post, rpc: rpc, params: inspect(params), error: inspect(reason))
        {:error, reason}

      {:error, %Jason.EncodeError{}} ->
        Logger.error(name: :http_post, rpc: rpc, params: inspect(params), error: "invalid params")
        {:error, "invalid params"}

      {:ok, %{error: error}} ->
        Logger.error(name: :http_post, rpc: rpc, params: inspect(params), error: inspect(error))
        {:error, error}

      other ->
        Logger.error(name: :http_post, rpc: rpc, params: inspect(params), error: inspect(other))
        {:error, "unknown error"}
    end
  end

  # @spec camel_to_underscore(map()) :: map()
  # def camel_to_underscore(map) when is_map(map) do
  #   Enum.reduce(map, %{}, fn {k, v}, acc ->
  #     Map.put(acc, k |> Macro.underscore() |> String.to_atom(), v)
  #   end)
  # end

  defp fetch_request_id() do
    case Application.fetch_env(:ethex, :request_id) do
      {:ok, value} -> value
      :error -> "ethex"
    end
  end
end
