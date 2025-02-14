defmodule Ethex.MixProject do
  use Mix.Project

  def project do
    [
      app: :ethex,
      version: "0.1.3",
      elixir: "~> 1.12",
      description: "Ethereum json-rpc implementation for multi-chain based on ex_abi",
      package: [
        licenses: ["GPL-3.0"],
        links: %{"GitHub" => "https://github.com/lxedge/ethex"}
      ],
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/lxedge/ethex"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Ethex.Supervisor, []},
      extra_applications: [:logger],
      env: [request_id: "ethex"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.37.1", only: :dev, runtime: false},
      {:jason, "~> 1.4"},
      {:httpoison, "~> 1.8"},
      {:rustler, "~> 0.36.1"},
      {:ex_abi, "~> 0.8.2"},
      {:ex_secp256k1, "~> 0.7.4"},
      {:mnemonic, "~> 0.3.1"}
    ]
  end
end
