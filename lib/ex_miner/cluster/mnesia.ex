defmodule ExMiner.Cluster.Mnesia do
  @dataset_table_name :dataset
  @centroid_table_name :centroid

  def init() do
    nodes = [Node.self()]
    :mnesia.create_schema(nodes)
    :mnesia.start()
    init_table(@dataset_table_name, [:data, :group], nodes)
    init_table(@centroid_table_name, [:worker, :centroid], nodes)
  end

  def init_table(table_name, attributes, nodes) do
    opts = [attributes: attributes, disc_copies: nodes]
    case :mnesia.create_table(table_name, opts) do
      {:aborted, {:already_exists, _table}} ->
            :mnesia.wait_for_tables([table_name], 5000)
      {:atomic, :ok} -> :ok
    end
  end

  #### crud ###

  def put(table_name, key, value), do:
    :mnesia.transaction(fn ->
      :mnesia.write({table_name, key, value})
    end)

  def put_all(table_name, objects), do:
    :mnesia.transaction(fn ->
      for object <- objects do
        {key, value} = case object do
          {d = {_, _}, g} -> {d, g}
          d -> {d, nil}
        end
        :mnesia.write({table_name, key, value})
      end
    end)

  def get_value_by_key(table_name, key) do
    {:atomic, [{table_name, key, value}]} = :mnesia.transaction(fn ->
      :mnesia.read({table_name, key})
    end)
    value
  end

  def get_keys_by_value(table_name, value) do
    {:atomic, results} = :mnesia.transaction(fn ->
      :mnesia.match_object({table_name, :_, value})
    end)
    Enum.map(results, fn {_, key, value} -> key end)
  end

  def get_all(table_name) do
    {:atomic, results} = :mnesia.transaction(fn ->
      :mnesia.match_object({table_name, :_, :_})
    end)
    Enum.map(results, fn {_, key, value} -> {key, value} end)
  end

  def delete_all(table_name) do
    {:atomic, keys} = :mnesia.transaction(fn ->
      :mnesia.all_keys(table_name)
    end)
    :mnesia.transaction(fn ->
      for key <- keys do
        :mnesia.delete({table_name, key})
      end
    end)
  end
end