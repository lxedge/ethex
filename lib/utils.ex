defmodule Ethex.Utils do
  @moduledoc """
  some utils
  """
  require Logger

  @doc false
  @spec http_post(String.t(), map()) :: any()
  def http_post(rpc, params) do
    req_body = Map.merge(%{jsonrpc: "2.0", id: fetch_request_id()}, params)

    with {:ok, encoded_data} <- Jason.encode(req_body),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.post(rpc, encoded_data, [{"content-type", "application/json"}]),
         {:ok, %{result: result}} <- Jason.decode(body, keys: :atoms) do
      {:ok, result}
    else
      {:error, %Jason.EncodeError{}} ->
        Logger.error(name: :http_post, rpc: rpc, params: inspect(params), error: "invalid params")
        {:error, "invalid params"}

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        Logger.error(name: :http_post, rpc: rpc, params: inspect(params), error: "timeout")
        {:error, "timeout"}

      {:ok, %{error: error}} ->
        Logger.error(name: :http_post, rpc: rpc, params: inspect(params), error: inspect(error))
        {:error, error}

      other ->
        Logger.error(name: :http_post, rpc: rpc, params: inspect(params), error: inspect(other))
        {:error, "unknown error"}
    end
  end

  defp fetch_request_id() do
    case Application.fetch_env(:ethex, :request_id) do
      {:ok, value} -> value
      :error -> "ethex"
    end
  end
end
