defmodule ExMiner.Cluster.Scheduler do
  use GenServer

  def start(scheduler_name), do: GenServer.start_link(__MODULE__, [], name: {:global, scheduler_name})

  def init(_), do: {:ok, []}

  def schedule(scheduler_name, repeat_args) do
    pid = GenServer.call(:whereis)
    Process.send_after(pid, {:repeat, repeat_args})
  end

  def handle_info({:repeat, {mod, func, args, interval}}, state) do
    apply(mod, func, args)
    Process.send_after(self(), {:repeat, {mod, func, args, interval}})
    {:noreply, state}
  end

  def handle_call(:whereis, _from, state), do: {:reply, self(), state}
end
