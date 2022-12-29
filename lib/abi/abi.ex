defmodule Ethex.Abi.Abi do
  @moduledoc """
  解析 ABI 文件
  """
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl GenServer
  def init(:ok) do
    {:ok, [:ok, 1, 2]}
  end

  def print_state(), do: GenServer.call(__MODULE__, :print_state)

  @impl GenServer
  def handle_call(:print_state, _, state), do: {:reply, state, state}
end
