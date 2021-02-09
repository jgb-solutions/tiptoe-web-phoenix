defmodule TipToe.Utils do
  alias TipToe.Repo

  def get_hash(struct) do
    hash = Enum.random(111_111..999_999)

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

  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  defp translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(TipToeWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(TipToeWeb.Gettext, "errors", msg, opts)
    end
  end
end
