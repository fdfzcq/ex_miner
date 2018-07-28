# ExMiner

A tool used for dynamically clustering datasets, currently only supports kmean algorithm.

Clusters can be visualised by using [ex_miner_frontend](https://github.com/fdfzcq/ex_miner_frontend)

To run the program locally:

If you have Elixir installed, simply do, but remember to remove the Mnesia table each time:

```bash
iex -S mix
```

If you are a docker player, do:

```bash
make run-docker
```

# Deprecated Version and Documentation (code not removed yet):

A dummy data clustering tool using explot.

Read more on [explot](https://github.com/JordiPolo/explot) if you don't have python3/matplotlib installed.

## Usage

To make two kmean clusters on a set of points [{1, 4}, {3, 5}, {6, 7}, {4, 6}], do:

```elixir
ExMiner.kmean([{1, 4}, {3, 5}, {6, 7}, {4, 6}])
```
Or

```elixir
list = (1..500) |> Enum.map(fn(n) -> {:rand.uniform(1000), :rand.uniform(1000)} end)
ExMiner.kmean(list)
```

Sample output:

![](sample.png?raw=true "sample")


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

