defmodule Ethex.Supervisor do
  @moduledoc false
  use Application

  def start(_, _) do
    children = [Ethex.Abi.Abi]
    opts = [name: Ethex.Supervisor, strategy: :one_for_one]

    Supervisor.start_link(children, opts)
  end
end
