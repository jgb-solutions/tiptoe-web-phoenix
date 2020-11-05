defmodule TipToe.Category do
  use Ecto.Schema
  import Ecto.Query
  alias TipToe.Repo
  import Ecto.Changeset
  alias TipToe.User
  alias TipToe.Category
  alias TipToe.Photo
  alias TipToe.Model

  schema "categories" do
    field :name, :string, unique: true
    field :slug, :string, unique: true

    has_many :photos, Photo
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
  end

  def random do
    query =
      from Category,
        order_by: fragment("RANDOM()"),
        limit: 1

    Repo.one(query)
  end
end
