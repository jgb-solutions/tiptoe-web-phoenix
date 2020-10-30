defmodule TipToeWeb.Resolvers.Category do
  alias TipToe.Repo
  import Ecto.Query
  alias TipToe.Category
  alias TipToe.Photo

  def all(_args, _resolution) do
    q =
      from g in Category,
        distinct: true,
        select: [:id, :name, :slug],
        join: t in Photo,
        on: g.id == t.category_id,
        where: fragment("exists (select id from `photos`)"),
        order_by: [asc: :name]

    {:ok, Repo.all(q)}
  end

  def find_by_slug(%{slug: slug}, _resolution) do
    case Repo.get_by(Category, slug: slug) do
      %Category{} = category -> {:ok, category}
      nil -> {:error, message: "Photo Not Found", code: 404}
    end
  end
end
