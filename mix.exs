defmodule Ethex.MixProject do
  use Mix.Project

  def project do
    [
      app: :ethex,
      version: "1.0.0",
      elixir: "~> 1.12",
      description: "Ethereum Contract interaction via json-rpc for multi-chain based on ex_abi",
      package: [
        licenses: ["GPL-3.0"],
        links: %{"GitHub" => "https://github.com/lxedge/ethex"}
      ],
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/lxedge/ethex",
      homepage_url: "https://hexdocs.pm/ethex",
      docs: &docs/0
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
      {:finch, "~> 0.19.0"},
      {:rustler, "~> 0.36.1"},
      {:ex_keccak, "~> 0.7.6"},
      {:ex_abi, "~> 0.8.2"},
      {:ex_secp256k1, "~> 0.7.4"},
      {:mnemonic, "~> 0.3.1"}
    ]
  end

  defp docs do
    [
      main: "Ethex",
      extras: ["README.md"]
    ]
  end
end
