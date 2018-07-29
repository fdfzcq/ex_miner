defmodule ExMiner.API.GetData do
  @moduledoc """
    Handler for /getData
    returns a json object with a list of data in the form of:
    {data: [[[x,y], group], ...]}
  """
  alias ExMiner.Cluster
  alias ExMiner.API

  def init(req, state) do
    response = get_cluster_data(req)
    new_req = API.Util.response(req, response)
    {:ok, new_req, state}
  end

  defp get_cluster_data(_body) do
    data = Cluster.get_all_data()
    %{data: format(data, [])}
  end

  defp format([], list), do: list
  defp format([{{x, y}, cluster}|t], list), do: format(t, [[[x,y], cluster]|list])
end
