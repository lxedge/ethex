defmodule Ethex.MixProject do
  use Mix.Project

  @source_url "https://github.com/lxedge/ethex"
  @version "1.1.1"

  def project do
    [
      app: :ethex,
      name: "Ethex",
      version: @version,
      elixir: "~> 1.12",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs()
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
      {:rustler, ">= 0.30.0"},
      {:ex_keccak, "~> 0.7.6"},
      {:ex_abi, "~> 0.8.2"},
      {:ex_secp256k1, "~> 0.7.4"},
      {:mnemonic, "~> 0.3.1"},
      {:ex_rlp, "~> 0.6.0"}
    ]
  end

  defp package do
    [
      description: "Ethereum Contract interaction via json-rpc for multi-chain based on ex_abi",
      maintainer: "lxedge",
      licenses: ["GPL-3.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      canonical: "https://hexdocs.pm/ethex",
      source_url: @source_url,
      homepage_url: @source_url,
      formatters: ["html"],
      extras: ["README.md"]
    ]
  end
end
