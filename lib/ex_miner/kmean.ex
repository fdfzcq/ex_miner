defmodule ExMiner.Kmean do

  defstruct(
    dist: 0.0,
    cluster: [],
    centroids: nil,
    group_a: [],
    group_b: []
    )

  def process(cluster) do
    cluster
    |> init_state
    |> init_centroids
    |> remove_centroids_from_cluster
    |> do_cluster
  end

  defp init_state(cluster) do
    %__MODULE__{
      cluster: cluster
    }
  end

  defp init_centroids(st) do
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
        true -> %{state|cluster: t, group_a: [h|group_a]}
        false -> %{state|cluster: t, group_b: [h|group_b]}
      end
    new_state
    |> recalculate_centroids
    |> do_cluster
  end

  defp recalculate_centroids(state) do
    # TODO optimize algorithm here
    centroids_a = state.group_a |> get_mean_point
    centroids_b = state.group_b |> get_mean_point
    %{state|centroids: {centroids_a, centroids_b}}
  end

  defp get_mean_point(group) do
    n = Enum.count(group)
    {x_sum, y_sum} = group
                     |> Enum.reduce({0, 0},
                        fn({x, y}, {xs, ys}) -> {xs + x, ys + y} end)
    {x_sum/n, y_sum/n}
  end

  defp get_distance({x1, y1}, {x2, y2}) do
    :math.sqrt(:math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2))
  end
end