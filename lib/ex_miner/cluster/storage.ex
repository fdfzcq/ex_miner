defmodule ExMiner.Cluster.Storage do
  use GenServer

  # dummy storage by using simple map values
  # TODO maybe use disk based storage

  def start(dataset), do: GenServer.start_link(__MODULE__, dataset, name: __MODULE__)

  def init(dataset) do
    {:ok, dataset}
  end

  def call(func, args\\[]), do: GenServer.call(__MODULE__, {func, args}) 

  def handle_call({func, args}, _from, state) do
    {res, new_state} = apply(__MODULE__, func, [state|args])
    {:reply, res, new_state}
  end

  def get_all(state), do: {state, state}

  def get_all_with_key(state, key), do: {get_all_with_key(state, key, []), state}
  defp get_all_with_key([], _key, list), do: :lists.reverse(list)
  defp get_all_with_key([{data, key}|t], key, list), do: get_all_with_key(t, key, [data|list])
  defp get_all_with_key([_|t], key, list), do: get_all_with_key(t, key, list)

  def get_first_with_key(state, key), do: {get_first_with_key(state, key, nil), state}
  defp get_first_with_key([], _key, nil), do: nil
  defp get_first_with_key([{data, key}|_], key, nil), do: data
  defp get_first_with_key([_|t], key, nil), do: get_first_with_key(t, key, nil)

  def move_to_last(state, data), do: {:ok, move_to_last(state, data, [], false)}
  defp move_to_last([], data, new_list, true) do
    :lists.reverse([data|new_list])
  end
  defp move_to_last([], data, new_list, false), do: new_list
  defp move_to_last([data|t], data, new_list, has_data?), do: move_to_last(t, data, new_list, true)
  defp move_to_last([v|t], data, new_list, has_data?), do: move_to_last(t, data, [v|new_list], has_data?)

  def take_over(state, data, new_group) do
    l = take_over(state, data, new_group, [])
    {res, _} = get_all_with_key(l, new_group)
    {res, l}
  end
  defp take_over([], _data, _new_group, new_list), do: :lists.reverse(new_list)
  defp take_over([{data, _}|t], data, new_group, new_list), do:
    take_over(t, data, new_group, [{data, new_group}|new_list])
  defp take_over([h|t], data, new_group, new_list), do: take_over(t, data, new_group, [h|new_list])
end