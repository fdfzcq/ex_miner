defmodule ExMiner do
  @moduledoc """
  Documentation for ExMiner.
  """
  use Supervisor
  alias ExMiner.API

  def start(_type, _args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      {ExMiner.Scheduler, [:job_scheduler]},
      {ExMiner.Cluster, []},
      {ExMiner.API, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
