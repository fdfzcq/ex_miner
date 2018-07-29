defmodule ExMiner.Cluster do
  @moduledoc """
  Interface for Cluster
  """
  alias ExMiner.Scheduler
  alias ExMiner.Cluster.{WorkerRegistry, Storage}
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init(_), do: {:ok, :foo}

  def start_cluster(opts \\ %{}), do: GenServer.call(__MODULE__, {:start_cluster, opts})

  def handle_call({:start_cluster, opts}, _from, _state) do
    cluster_n = opts[:cluster_n] || 3
    algo = opts[:algorithm] || :kmean
    dataset_size = opts[:dataset_size] || 500
    data_range = opts[:data_range] || 1000
    cluster_interval = opts[:cluster_interval] || 500

    dataset = (1..dataset_size) |> Enum.map(fn(_) -> {:rand.uniform(data_range), :rand.uniform(data_range)} end)
    res = case WorkerRegistry.start(cluster_n, algo, dataset) do
      :ok ->
        Scheduler.schedule(:job_scheduler, {WorkerRegistry, :start_process, [cluster_n, algo], cluster_interval})
        :ok
      err -> err
    end
    {:reply, res, :foo}
  end

  def get_all_data(), do: Storage
    |> Process.whereis
    |> get_all_data()

  defp get_all_data(nil), do: [] 
  defp get_all_data(_), do: Storage.call(:get_all, [])
end
