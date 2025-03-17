defmodule Ethex.RpcMethods.NetRpc do
  @moduledoc """
  https://www.quicknode.com/docs/ethereum/net_version
  """
  alias Ethex.Utils.Rpc

  @doc """
  Returns true if client is actively listening for network connections.
  """
  def net_listening(rpc) do
    Rpc.http_post(rpc, %{method: "net_listening", params: []})
  end

  @doc """
  Returns number of peers currently connected to the client.
  """
  def net_peer_count(rpc) do
    Rpc.http_post(rpc, %{method: "net_peerCount", params: []})
  end

  @doc """
  Returns the current network id.
  """
  def net_version(rpc) do
    Rpc.http_post(rpc, %{method: "net_version", params: []})
  end
end
