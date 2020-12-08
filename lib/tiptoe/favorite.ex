defmodule TipToe.Favorite do
  use Ecto.Schema
  import Ecto.Changeset

  alias TipToe.User
  alias TipToe.Photo

  schema "favorites" do
    belongs_to :user, User
    belongs_to :photo, Photo

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(favorite, attrs) do
    favorite
    |> cast(attrs, [])
    |> validate_required([])
  end
end
