defmodule ExMiner.Cluster.Worker do
  alias ExMiner.Cluster.Storage
  alias ExMiner.Algo
  use GenServer

  defstruct(
    call_back_method: nil,
    next_worker_name: nil,
    cluster_number: 0,
    metadata: %{}
  )

  def init({algo, n, cluster_number}) do
    state = %__MODULE__{
      call_back_method: call_back_method(algo),
      next_worker_name: get_next_worker(cluster_number, n),
      cluster_number: cluster_number
    }
    {:ok, state}
  end

  def handle_cast(:do_process, state) do
    data = GenServer.call(Storage, {:get_first_with_key}, [state.cluster_number])
    local_dist = state.call_back_method.distance_to_centroid(state)
    next_dist = GenServer.call(state.next_worker_name, {:calculate_dist, data})
    # TBC
    {:noreply, state}
  end

  def handle_call(:init_cluster, _from, state) do
    dataset = GenServer.call(Storage, {:get_all_with_key, [state.cluster_number]})
    {:reply, :ok, %{state|metadata: state.call_back_method.init_metadata(dataset)}}
  end

  defp call_back_method(:kmean), do: Algo.Kmean
  defp call_back_method(_), do: Algo.Default

  defp get_next_worker(n, n), do: {:global, {:cluster, 1}}
  defp get_next_worker(n, _), do: {:global, {:cluster, n + 1}}

end