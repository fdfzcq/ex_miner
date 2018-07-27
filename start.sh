#!/bin/bash
cd /opt/ex_miner
mix local.hex --force && mix local.rebar --force && mix deps.get && iex -S mix
