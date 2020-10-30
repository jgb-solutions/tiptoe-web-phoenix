defmodule TipToe.Helper do
  def append_if(list, condition, item) do
    if condition, do: list ++ [item], else: list
  end
end
