defmodule ExMiner.Algo.Kmean do
  @behaviour ExMiner.Algo.Default

  defstruct(
    centroid: nil
  )

  def init_metadata(dataset) do
    %__MODULE__{centroid: calculate_centroid(dataset)}
  end

  defp calculate_centroid(dataset) do
    n = Enum.count(dataset)
    {x_sum, y_sum} = dataset
                     |> Enum.reduce({0, 0},
                        fn({x, y}, {xs, ys}) -> {xs + x, ys + y} end)
    {div(10 * x_sum, n)/10, div(10 * y_sum, n)/10}
  end

  def get_distance({x1, y1}, {x2, y2}) do
    :math.sqrt(:math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2))
  end
end