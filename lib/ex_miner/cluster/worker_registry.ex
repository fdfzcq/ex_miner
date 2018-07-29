defmodule ExMiner.Cluster.WorkerRegistry do
  alias ExMiner.Cluster.Worker, as: ClusterWorker
  alias ExMiner.Cluster.Storage, as: ClusterStorage

  # start worker registry

  def start(no_of_clusters, algo, dataset), do:
    [keys: :unique, name: algo]
    |> Registry.start_link()
    |> start(no_of_clusters, algo, dataset)

  defp start({:ok, _}, no_of_clusters, algo, dataset) do
    start_storage(no_of_clusters, dataset)
    spawn_cluster(no_of_clusters, algo)
    init_cluster(no_of_clusters, algo)
    start_process(no_of_clusters, algo)
    :ok
  end
  defp start(err, _, _, _), do: err

  # init worker with dataset

  defp start_storage(n, dataset) do
    dataset
    |> Enum.with_index()
    |> Enum.map(fn {data, index} -> {data, rem(index, n) + 1} end)
    |> ClusterStorage.start()
  end

  def spawn_cluster(no_of_clusters, algo),
    do:
      1..no_of_clusters
      |> Enum.each(&start_cluster_worker(&1, algo, no_of_clusters))

  defp start_cluster_worker(cluster_number, algo, no_of_clusters) do
    {:ok, pid} =
      GenServer.start_link(
        ClusterWorker,
        {algo, no_of_clusters, cluster_number},
        name: {:global, {:cluster, cluster_number}}
      )
    Registry.register(algo, cluster_number, pid)
  end

  def init_cluster(n, algo) do
    keys = 1..n
    Enum.each(keys, &init_workers_with_data(&1, algo))
  end

  defp init_workers_with_data(key, algo) do
    Registry.dispatch(algo, key, fn [{_, pid}] -> GenServer.call(pid, :init_cluster) end)
  end

  # TODO: calculation, cluster, store data, api round robin
  def start_process(no_of_clusters, algo), do: 1..no_of_clusters |> Enum.each(&process(algo, &1))

  def process(algo, key) do
    Registry.dispatch(algo, key, fn [{_, pid}] -> GenServer.cast(pid, :do_process) end)
  end
end
