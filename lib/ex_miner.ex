defmodule ExMiner do
  @moduledoc """
  Documentation for ExMiner.
  """
  def plot(values, options\\%{}) do
    plot = Explot.new
    {x_list, y_list} = values
                       |> Enum.reduce({[],[]},
                            fn({x, y}, {xs, ys}) ->
                                  {[x|xs], [y|ys]} end)
    color = options |> Map.get(:color, 'ro')
    Explot.plot_command(plot, "plot(#{inspect x_list},#{inspect y_list},'#{color}')")
    Explot.show(plot)
  end

end
