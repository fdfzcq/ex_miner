defmodule ExMiner.API do
  alias ExMiner.Cluster.Storage
  def init(req, state) do
    response = get_cluster_data(req)
    new_req = :cowboy_req.reply(200, %{"content-type" => "application/json"}, Poison.encode!(response), req)
    {:ok, new_req, state}
  end

  defp get_cluster_data(_body) do
    data = Storage.call(:get_all, [])
    %{data: format(data, [])}
  end

  defp format([], list), do: list
  defp format([{{x, y}, cluster}|t], list), do: format(t, [[[x,y], cluster]|list])
end
