defmodule ExMiner.API.ClusterData do
  @moduledoc """
    Handler for /clusterData
    the request should use a post method and should specify the dataset size, cluster numbers and cluster algorithm
    by calling the method ex_miner will generate a set of random points and start clustering
    returns a json object {success: true} if succeeds, or {error: "reason"}
  """
  alias ExMiner.Cluster
  alias ExMiner.API

  def init(req, state) do
    new_req = process(req, state)
    {:ok, new_req, state}
  end

  def process(req = %{method: "POST"}, state), do: process(:cowboy_req.read_body(req), req, state)
  def process(req = %{method: method}, _state), do:
    apply(:cowboy_req, :reply, API.Error.wrong_request_method(method, req))
  
  defp process({:ok, body, _req}, req, state), do:
    body
    |> Poison.decode!(keys: :atoms!)
    |> call_cluster(req)
    |> form_response(req)
  defp process(res, req, _state), do: apply(:cowboy_req, :reply, API.Error.wrong_request_body(res, req))

  # cluster method
  defp call_cluster(opts = %{algorithm: "kmean"}, _req), do: Cluster.start_cluster(%{opts|algorithm: :kmean})
  defp call_cluster(%{algorithm: algo}, req), do:
    apply(:cowboy_req, :reply, API.Error.invalid_cluster_algo(algo, req))
  defp call_cluster(opts, _req), do: Cluster.start_cluster(opts)

  defp form_response(:ok, req) do
    response = %{success: true}
    API.Util.response(req, response)
  end
  defp form_response(res, req), do: apply(:cowboy_req, :reply, API.Error.process_err(res, req))
end
