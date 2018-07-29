defmodule ExMiner.API.Util do
  @moduledoc """
  shared function for api
  """
 
  def response(request, response) do
    req = :cowboy_req.set_resp_header("access-control-allow-methods", "POST, GET, OPTIONS", request)
    req = :cowboy_req.set_resp_header("access-control-allow-origin", "*", req)
    :cowboy_req.reply(200, %{"content-type" => "application/json"}, Poison.encode!(response), req)
  end
end