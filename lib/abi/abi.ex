defmodule Ethex.Abi.Abi do
  @moduledoc false
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec print_state :: map()
  def print_state(), do: GenServer.call(__MODULE__, :print_state)

  @spec add_abi(String.t(), any) :: :ok | :error
  def add_abi(name, abi_file_path) do
    GenServer.call(__MODULE__, {:add_abi, name, abi_file_path})
  end

  @spec get_selectors_by_name(String.t()) :: list()
  def get_selectors_by_name(name) do
    GenServer.call(__MODULE__, {:get_selectors_by_name, name})
  end

  @impl GenServer
  def init(:ok), do: {:ok, %{}}

  @impl GenServer
  def handle_call(:print_state, _, state), do: {:reply, state, state}

  @impl GenServer
  def handle_call({:add_abi, name, abi_file_path}, _, state) do
    with {:ok, str} <- File.read(abi_file_path),
         {:ok, abi} <- Jason.decode(str) do
      fs = ABI.parse_specification(abi, include_events?: true)
      {:reply, :ok, Map.put(state, name, fs)}
    else
      _ -> {:reply, :error, state}
    end
  end

  @impl GenServer
  def handle_call({:get_selectors_by_name, name}, _, state) do
    {:reply, Map.get(state, name), state}
  end
end
