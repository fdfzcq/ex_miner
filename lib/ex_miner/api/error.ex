defmodule ExMiner.API.Error do
  @moduledoc """
    Error types and status code
  """

  def wrong_request_method(method, req), do:
    [400, %{"content-type" => "text/plain"}, "Wrong Request Method #{method}", req]

  def wrong_request_body(res, req), do:
    [400, %{"content-type" => "text/plain"}, "Invalid Request Body #{inspect res}", req]

  def process_err(err, req), do:
    [500, %{"content-type" => "text/plain"}, "#{inspect(err)}", req]

  def invalid_cluster_algo(algo, req), do:
    [500, %{"content-type" => "text/plain"}, "Invalid Cluster algorithm #{algo}", req]
end
