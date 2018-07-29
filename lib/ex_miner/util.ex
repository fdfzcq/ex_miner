defmodule ExMiner.Util do
  defmodule Str do
    @doc """
    Functions for manipulating binary strings and charlists, this will return a binary string

    ## Example
      iex> ExMiner.Util.capitalise("abc")
      "Abc"
      iex> ExMiner.Util.capitalise('abc')
      "Abc"
      iex> ExMiner.Util.capitalise("abC")
      "AbC"
      iex> ExMiner.Util.capitalise("")
      ""
    """
    def capitalize(string) when is_bitstring(string), do:
      capitalize(String.to_charlist(string))
    def capitalize([h|t]), do: :erlang.list_to_binary([h-32|t])

  end
end
