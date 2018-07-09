defmodule ExMiner.MessageHandler.MQ do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    options = Application.get_env(:ex_miner, :mq)
    queue_name = Keyword.get(options, :queue)
    exchange_name = Keyword.get(options, :exch)
    {:ok, conn} = Connection.open(options)
    {:ok, chan} = Channel.open(conn)
    AMQP.Queue.declare(chan, queue_name)
    AMQP.Exchange.declare(chan, exchange_name)
    :ok = AMQP.Queue.bind(chan, queue_name, exchange_name)

    state = %{chan: chan, exch: exchange_name}
    {:ok, options}
  end

  def publish(r_key, message), do: GenServer.cast(__MODULE__, {:publish, r_key, message})
    
  def handle_cast({:publish, r_key, message}, state = %{chan: chan, exch: exch}) do
    AMQP.Basic.publish(chan, exch, r_key, message)
    {:noreply, state}
  end
end
