FROM elixir

COPY . /opt/ex_miner

ENTRYPOINT ["/opt/ex_miner/start.sh"]
CMD        [ "console" ]
