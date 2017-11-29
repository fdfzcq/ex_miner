defmodule ExMiner.Kmean do

  defstruct(
    dist: 0.0,
    cluster: [],
    centroids: nil,
    group_a: [],
    group_b: []
    )

  def process(cluster, opts) do
    cluster
    |> init_state
    |> init_centroids?(opts)
    #|> remove_centroids_from_cluster
    |> cluster
    #|> do_cluster
  end

  defp init_state(cluster) do
    %__MODULE__{
      cluster: cluster
    }
  end

  defp init_centroids?(st, opts) do
    case Map.get(opts, :init_centroids, nil) do
      nil -> init_centroids(st, true)
      centroids -> init_centroids(%{st|centroids: centroids}, false)
    end
  end

  defp init_centroids(st, false), do: st
  defp init_centroids(st, true) do
    st.cluster
    |> Enum.reduce(st, fn(point, state) ->
        p2 = state.cluster
             |> Enum.max_by(&(get_distance(point, &1)))
        dis = get_distance(p2, point)
        case state.dist < dis do
          true -> %{state|dist: dis, centroids: {point, p2},
                          group_a: [point], group_b: [p2]}
          false -> state
        end
    end)
  end

  defp cluster(st) do
    cluster = st.cluster
    result = do_cluster(st)
    case result.centroids == st.centroids do
      true -> IO.puts("Get final centroids #{inspect result.centroids}")
              result
      _false -> new_st = %{result|cluster: cluster}
                IO.puts("Reclustering ... ")
                cluster(new_st)
    end
  end

  defp remove_centroids_from_cluster(state) do
    new_cluster = state.cluster
                  |> Enum.filter(fn(p) -> !Enum.any?(state.group_a, &(&1 == p))
                                          &&
                                          !Enum.any?(state.group_b, &(&1 == p)) end)
    %{state|cluster: new_cluster}
  end

  defp do_cluster(state = %{cluster: []}), do: state
  defp do_cluster(state = %{cluster: [h|t], centroids: {p1, p2},
      group_a: group_a, group_b: group_b}) do
    dist_a = get_distance(h, p1)
    dist_b = get_distance(h, p2)
    new_state =
      case dist_a < dist_b do
        true -> %{state|cluster: t, group_a: [h|group_a], group_b: Enum.filter(group_b, &(&1 != h))}
        false -> %{state|cluster: t, group_b: [h|group_b], group_a: Enum.filter(group_a, &(&1 != h))}
      end
    new_state
    |> recalculate_centroids
    |> do_cluster
  end

  defp recalculate_centroids(state = %{centroids: {c_a, c_b}}) do
    # TODO optimize algorithm here
    centroids_a = state.group_a |> get_mean_point(c_a)
    centroids_b = state.group_b |> get_mean_point(c_b)
    %{state|centroids: {centroids_a, centroids_b}}
  end

  defp get_mean_point([], c), do: c
  defp get_mean_point(group, _) do
    n = Enum.count(group)
    {x_sum, y_sum} = group
                     |> Enum.reduce({0, 0},
                        fn({x, y}, {xs, ys}) -> {xs + x, ys + y} end)
    {div(10 * x_sum, n)/10, div(10 * y_sum, n)/10}
  end

  defp get_distance({x1, y1}, {x2, y2}) do
    :math.sqrt(:math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2))
  end
end