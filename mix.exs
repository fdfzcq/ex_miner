defmodule ExMiner.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_miner,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ExMiner, []},
      applications: [:explot, :cowboy]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, git: "https://github.com/ninenines/cowboy.git", tag: "2.1.0", override: true},
      {:ranch, git: "https://github.com/ninenines/ranch", tag: "1.4.0", override: true},
      {:explot, "~> 0.1.0"}
    ]
  end
end
