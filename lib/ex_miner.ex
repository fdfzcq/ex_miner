defmodule ExMiner do
  @moduledoc """
  Documentation for ExMiner.
  """
  use GenServer
  alias ExMiner.Kmean

  def start(_type, _args), do: __MODULE__.start_link()

  def start_link(), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init([]) do
    pid = Explot.new
    {:ok, pid}
  end

  def plot(values, opts\\nil) do
    :ok = GenServer.call(__MODULE__, {:plot, values, opts})
    GenServer.call(__MODULE__, :show)
  end

  def kmean(cluster, opts\\nil) do
    :kmean = GenServer.call(__MODULE__, {:plot, cluster, :kmean, opts}, 30_000)
    GenServer.call(__MODULE__, :show, :infinity)
  end

  # def plot(values, :kmean, options\\%{}) do
  #   options =
  # end

  def handle_call({:plot, values, opts}, _from, pid) do
    plot = plotted?(pid)
    do_plot(values, plot)
    {:reply, :ok, plot}
  end

  def handle_call({:plot, cluster, :kmean, opts}, _from, pid) do
    plot = plotted?(pid)
    kmean = Kmean.process(cluster)
    do_plot(kmean.group_a, plot, %{color: 'ro'})
    do_plot(kmean.group_b, plot, %{color: 'bo'})
    {:reply, :kmean, plot}
  end

  def handle_call(:show, _from, pid) do
    plot = plotted?(pid)
    Explot.xlabel(pid, "x")
    Explot.ylabel(pid, "y")
    Explot.show(plot)
    {:reply, :ok, nil}
  end

  defp plotted?(nil), do: Explot.new
  defp plotted?(pid), do: pid

  defp do_plot(values, plot, options\\%{}) do
    {x_list, y_list} = values
                       |> Enum.reduce({[],[]},
                            fn({x, y}, {xs, ys}) ->
                                  {[x|xs], [y|ys]} end)
    color = options |> Map.get(:color, 'ro')
    command = "plot([" <> Enum.join(x_list, ",") <> "],[" <> Enum.join(y_list, ",") <> "],'#{color}')"
    IO.puts command
    Explot.plot_command(plot, command)
  end

end
