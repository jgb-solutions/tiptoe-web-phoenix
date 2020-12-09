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
  def changeset(%__MODULE__{} = favorite, attrs) do
    favorite
    |> cast(attrs, [:photo_id, :user_id])
    |> validate_required([:photo_id, :user_id])
  end
end
