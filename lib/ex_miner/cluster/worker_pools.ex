defmodule ExMiner.Cluster.WorkerRegistry do
  alias ExMiner.Cluster.Worker, as: ClusterWorker
  alias ExMiner.Cluster.Storage, as: ClusterStorage
  use GenServer

  # start worker registry

  def start(no_of_clusters, algo, dataset) do
    Registry.start_link(keys: :unique, name: algo)
    spawn_cluster(no_of_clusters, algo)
    init_cluster(no_of_clusters, dataset, algo)
  end

  def spawn_cluster(no_of_clusters, algo), do: (1..no_of_clusters)
    |> Enum.each(&start_cluster_worker(&1, &2, no_of_clusters))

  defp start_cluster_worker(cluster_number, algo, no_of_clusters) do
    {:ok, pid} = GenServer.start_link(ClusterWorker, {algo, no_of_clusters, cluster_number},
      name: {:global, {:cluster, cluster_number}})
    Registry.register(algo, cluster_number, pid)
  end

  # init worker with dataset

  def init_cluster(n, dataset, algo) do
    keys = (1..n)
    init_storage_with_data(dataset, Enum.count(keys))
    Enum.each(keys, &init_workers_with_data(&1, algo))
  end

  defp init_workers_with_data(key, algo) do
    Registry.dispatch(algo, key, fn pid -> GenServer.call(pid, :init_cluster) end)
  end

  defp init_storage_with_data(dataset, n) do
    dataset
    |> Enum.with_index(dataset)
    |> Enum.map(fn({data, index}) -> {data, rem(index, n) + 1} end)
    |> Enum.into(%{})
    |> ClusterStorage.start
  end

  # TODO: calculation, cluster, store data, api round robin

  def start_process(algo) do
    init_key = 1
    Registry.dispatch(algo, init_key, fn pid -> GenServer.call(pid, :do_process) end)
  end

end