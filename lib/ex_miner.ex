defmodule ExMiner do
  @moduledoc """
  Documentation for ExMiner.
  """
  use GenServer
  alias ExMiner.Kmean
  alias ExMiner.Cluster.{Scheduler, WorkerRegistry}

  @port 8990

  def start(_type, _args) do
    start()

    ranch_options = [{:port, @port}]
    dispatch = :cowboy_router.compile([{:'_', [{'/data', ExMiner.API, []}]}])
    cowboy_options = %{
      env: %{dispatch: dispatch},
      comress: true,
      timeout: 30_000
    }
    {:ok, _} = :cowboy.start_clear(:http, ranch_options, cowboy_options)

    #MQ.start_link()
  end

  def start() do
    Scheduler.start(:job_scheduler)
    dataset = (1..500) |> Enum.map(fn(_) -> {:rand.uniform(1000), :rand.uniform(1000)} end)
    WorkerRegistry.start(3, :kmean, dataset)
    Scheduler.schedule(:job_scheduler, {ExMiner.Cluster.WorkerRegistry, :start_process, [3, :kmean], 500})
  end

  ############################### deprecated ###################################

  def start_link(), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init([]) do
    pid = Explot.new()
    {:ok, pid}
  end

  def plot(values, opts \\ %{}) do
    :ok = GenServer.call(__MODULE__, {:plot, values, opts})
    GenServer.call(__MODULE__, :show)
  end

  def kmean(cluster, opts \\ %{}) do
    :kmean = GenServer.call(__MODULE__, {:plot, cluster, :kmean, opts}, :infinity)
    GenServer.call(__MODULE__, :show, :infinity)
  end

  # def plot(values, :kmean, options\\%{}) do
  #   options =
  # end

  def handle_call({:plot, values, _opts}, _from, pid) do
    plot = plotted?(pid)
    do_plot(values, plot)
    {:reply, :ok, plot}
  end

  def handle_call({:plot, cluster, :kmean, opts}, _from, pid) do
    plot = plotted?(pid)
    kmean = Kmean.process(cluster, opts)
    do_plot(kmean.group_a, plot, %{color: 'ro'})
    do_plot(kmean.group_b, plot, %{color: 'bo'})
    do_plot(Tuple.to_list(kmean.centroids), plot, %{color: 'ko'})
    {:reply, :kmean, plot}
  end

  def handle_call(:show, _from, pid) do
    plot = plotted?(pid)
    Explot.xlabel(pid, "x")
    Explot.ylabel(pid, "y")
    Explot.show(plot)
    {:reply, :ok, nil}
  end

  defp plotted?(nil), do: Explot.new()
  defp plotted?(pid), do: pid

  defp do_plot(values, plot, options \\ %{}) do
    {x_list, y_list} =
      values
      |> Enum.reduce({[], []}, fn {x, y}, {xs, ys} ->
        {[x | xs], [y | ys]}
      end)

    color = options |> Map.get(:color, 'ro')

    command =
      "plot([" <> Enum.join(x_list, ",") <> "],[" <> Enum.join(y_list, ",") <> "],'#{color}')"

    Explot.plot_command(plot, command)
  end
end
