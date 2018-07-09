# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ex_miner, :mq, [
  username:     "guest",
  password:     "guest",
  host:         "localhost",
  port:         5672,
  virtual_host: "/",
  queue:        "ex_miner_queue",
  exch:         "ex_miner"
]
