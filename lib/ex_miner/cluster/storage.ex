defmodule ExMiner.Cluster.Storage do
  use GenServer

  # dummy storage by using simple map values
  # TODO maybe use disk based storage

  def start(dataset), do: GenServer.start_link(__MODULE__, dataset, name: __MODULE__)

  def init(dataset) do
    {:ok, dataset}
  end

  def handle_call({func, args}, _from, state) do
    {res, new_state} = apply(__MODULE__, func, [state|args])
    {:reply, res, new_state}
  end

  def get_all_with_key(state, key), do: {get_all_with_key(state, key, []), state}
  defp get_all_with_key([], _key, list), do: :lists.reverse(list)
  defp get_all_with_key([{data, key}|t], key, list), do: get_all_with_key(t, key, [data|list])
  defp get_all_with_key([_|t], key, list), do: get_all_with_key(t, key, list)

  def get_first_with_key(state, key), do: {get_first_with_key(state, key, nil), state}
  defp get_first_with_key([], _key, nil), do: nil
  defp get_first_with_key([{data, key}|_], key, nil), do: data
  defp get_first_with_key([_|t], key, nil), do: get_first_with_key(t, key, nil)

end