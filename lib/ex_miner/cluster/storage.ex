defmodule ExMiner.Cluster.Storage do
  use GenServer
  alias ExMiner.Cluster.Mnesia

  @dataset_table_name :dataset
  @centroid_table_name :centroid

  # dummy storage by using simple map values
  # TODO maybe use disk based storage

  def start(dataset), do: GenServer.start_link(__MODULE__, dataset, name: __MODULE__)

  def init(dataset) do
    Mnesia.init()
    init_with_dataset(dataset)
    {:ok, :foo}
  end

  def call(func, args \\ []), do: GenServer.call(__MODULE__, {func, args})

  def handle_call({func, args}, _from, state) do
    res = apply(__MODULE__, func, args)
    {:reply, res, state}
  end

  def get_all(), do: Mnesia.get_all(@dataset_table_name)

  def get_all_with_key(key), do: Mnesia.get_keys_by_value(@dataset_table_name, key)

  def get_first_with_key(key), do: Enum.at(Mnesia.get_keys_by_value(@dataset_table_name, key), 0)

  def next_with_key({data, key}),
    do: next_with_key(Mnesia.get_keys_by_value(@dataset_table_name, key), data, [])

  def get_centroid_by_worker_name(worker_name),
    do: Mnesia.get_value_by_key(@centroid_table_name, worker_name)

  def update_centroid(worker_name, centroid) do
    Mnesia.put(@centroid_table_name, worker_name, centroid)
  end

  defp next_with_key([], _data, []), do: nil
  defp next_with_key([], _data, l), do: Enum.at(l, -1)
  defp next_with_key([data|t], data, l), do: next_with_key(t, data, [data|l])
  defp next_with_key([next|_t], data, [data|_l]), do: next
  defp next_with_key([h|t], data, l), do: next_with_key(t, data, [h|l])

  def take_over(data, new_group) do
    Mnesia.put(@dataset_table_name, data, new_group)
  end

  def init_with_dataset(dataset), do: Mnesia.put_all(@dataset_table_name, dataset)
end
