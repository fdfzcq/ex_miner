defmodule ExMiner.Cluster.Worker do
  alias ExMiner.Cluster.Storage
  alias ExMiner.Algo
  use GenServer

  defstruct(
    call_back_method: nil,
    cluster_number: 0,
    data_to_process: nil,
    next_worker_name: nil,
    centroid: nil
  )

  def init({algo, n, cluster_number}) do
    state = %__MODULE__{
      call_back_method: call_back_method(algo),
      cluster_number: cluster_number,
      data_to_process: Storage.call(:get_first_with_key, [cluster_number]),
      next_worker_name: get_next_worker(cluster_number, n)
    }
    {:ok, %{state | centroid: update_centroid(state)}}
  end

  def handle_cast(:do_process, state) do
    data = data_to_process(state.data_to_process, state)
    local_dist = calculate_dist(data, worker_name(state.cluster_number))
    next_dist = calculate_dist(data, state.next_worker_name)
    maybe_move_data(data, state, local_dist > next_dist)
    next_data = Storage.next_with_key(data)
    centroid = update_centroid(state)
    {:noreply, %{state | data_to_process: next_data, centroid: centroid}}
  end

  def handle_cast({:take_over, data}, state) do
    GenServer.call(Storage, {:take_over, [data, state.cluster_number]})
    centroid = update_centroid(state)
    {:noreply, %{state | centroid: centroid}}
  end

  def handle_call(:init_cluster, _from, state) do
    centroid = update_centroid(state)
    {:reply, :ok, %{state | centroid: centroid}}
  end

  defp maybe_move_data(_data, state, false), do: state

  defp maybe_move_data(data, state, true) do
    GenServer.cast(state.next_worker_name, {:take_over, data})
    state
  end

  defp calculate_dist(data, worker_name) do
    next_centroid = Storage.call(:get_centroid_by_worker_name, [worker_name])
    Algo.Kmean.get_distance(data, next_centroid)
  end

  defp update_centroid(state) do
    dataset = Storage.call(:get_all_with_key, [state.cluster_number])
    centroid = apply(state.call_back_method, :calculate_centroid, [dataset])
    case centroid == state.centroid do
      true -> :ok
      false -> Storage.call(:update_centroid, [worker_name(state.cluster_number), centroid])
    end
    centroid
  end

  defp call_back_method(:kmean), do: Algo.Kmean
  defp call_back_method(_), do: Algo.Default

  defp worker_name(n), do: {:global, {:cluster, n}}

  defp get_next_worker(n, n), do: {:global, {:cluster, 1}}
  defp get_next_worker(n, _), do: {:global, {:cluster, n + 1}}

  defp data_to_process(data = {_, _}, _), do: data
  defp data_to_process(_, state), do: Storage.call(:get_first_with_key, [state.cluster_number])
end
