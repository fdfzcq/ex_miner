defmodule ExMiner.API do
  alias ExMiner.Util
  @moduledoc """
  API interface
  """

  @default_port 8990
  @endpoints ~w(getData clusterData)

  def start_link() do
    ranch_options = [{:port, port()}]
    dispatch = :cowboy_router.compile([{:'_', endpoints()}])
    cowboy_options = %{
      env: %{dispatch: dispatch},
      compress: true,
      timeout: 30_000
    }
    {:ok, _} = :cowboy.start_clear(:http, ranch_options, cowboy_options)
  end

  def child_spec(_) do
    Supervisor.Spec.worker(__MODULE__, [])
  end

  defp endpoints(), do: @endpoints
    |> Enum.map(&to_endpoint/1)

  defp to_endpoint(endpoint), do:
    {
      [?/|String.to_charlist(endpoint)],
      String.to_atom("Elixir.ExMiner.API." <> Util.Str.capitalize(endpoint)),
      []
    }

  defp port(), do: Application.get_env(:ex_miner, :api_port, @default_port)
end
