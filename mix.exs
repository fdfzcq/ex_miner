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
      applications: [:explot]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:explot, "~> 0.1.0"}
    ]
  end
end
