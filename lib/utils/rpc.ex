defmodule Ethex.Utils.Rpc do
  @moduledoc false
  require Logger

  @type error :: atom()

  @spec http_post(String.t(), any()) :: {:ok, any()} | {:error, error()}
  def http_post(rpc, params) do
    headers = [{"Content-Type", "application/json"}]
    body = Map.merge(%{jsonrpc: "2.0", id: fetch_request_id()}, params)
    opts = [request_timeout: 30_000, receive_timeout: 5_000]

    with {:ok, body_str} <- Jason.encode(body),
         %Finch.Request{} = req <- Finch.build(:post, rpc, headers, body_str, opts),
         {:ok, %Finch.Response{status: 200, body: body}} <- Finch.request(req, Ethex.Finch),
         {:ok, %{result: result}} <- Jason.decode(body, keys: :atoms) do
      {:ok, result}
    else
      {:error, %Jason.EncodeError{}} ->
        Logger.error("Ethex.Utils.http_post request body error: #{inspect(params)}")
        {:error, :invalid_params}

      {:error, %Mint.TransportError{reason: :nxdomain}} ->
        Logger.error("Ethex.Utils.http_post network error: nxdomain")
        {:error, :network_error}

      {_, %Finch.Response{status: status}} ->
        Logger.error("Ethex.Utils.http_post response status error: #{status}")
        {:error, :response_error}

      {:error, %Jason.DecodeError{}} ->
        Logger.error("Ethex.Utils.http_post response body error")
        {:error, :response_error}

      {:ok, %{error: %{code: errcode, message: errmsg}}} ->
        Logger.error("Ethex.Utils.http_post response error: #{errcode}, #{errmsg}")
        {:error, :"rpc_error_#{errcode}"}

      other ->
        Logger.error("Ethex.Utils.http_post unknown error: #{inspect(other)}")
        {:error, :unknown_error}
    end
  end

  @spec fetch_request_id() :: String.t()
  def fetch_request_id() do
    case Application.fetch_env(:ethex, :request_id) do
      {:ok, value} -> value
      :error -> "ethex"
    end
  end
end
