defmodule TipToe.Utils do
  alias TipToe.Repo

  def get_hash(struct) do
    hash = Enum.random(100_000..999_999)

    case Repo.get_by(struct, hash: hash) do
      %struct{} ->
        get_hash(struct)

      nil ->
        hash
    end
  end

  def make_order_by_list(order_by_list) do
    Enum.map(order_by_list, fn %{field: field, order: order} ->
      {String.to_atom(String.downcase(order)), String.to_atom(field)}
    end)
  end
end
