# ExMiner

A dummy data clustering tool using explot.

Read more on [explot](https://github.com/JordiPolo/explot) if you don't have python3/matplotlib installed.

## Usage

To make two kmean clusters on a set of points [{1, 4}, {3, 5}, {6, 7}, {4, 6}], do:

```elixir
ExMiner.kmean([{1, 4}, {3, 5}, {6, 7}, {4, 6}])
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_miner` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_miner, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_miner](https://hexdocs.pm/ex_miner).

