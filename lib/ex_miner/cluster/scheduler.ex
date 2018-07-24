defmodule ExMiner.Cluster.Scheduler do
  use GenServer

  def start(scheduler_name), do: GenServer.start_link(__MODULE__, [], name: {:global, scheduler_name})

  def init(_), do: {:ok, []}

  def schedule(scheduler_name, repeat_args = {mod, func, args, interval}) do
    pid = GenServer.call(__MODULE__, :whereis)
    Process.send_after(pid, {:repeat, repeat_args}, interval)
  end

  def stop(), do: GenServer.stop(__MODULE__)

  def handle_info({:repeat, {mod, func, args, interval}}, state) do
    apply(mod, func, args)
    Process.send_after(self(), {:repeat, {mod, func, args, interval}}, interval)
    {:noreply, state}
  end

  def terminate(:normal, _state) do
    IO.puts "scheduler stopped"
    state
  end

  def handle_call(:whereis, _from, state), do: {:reply, self(), state}
end
