defmodule TipToe.Follower do
  use Ecto.Schema
  import Ecto.Changeset

  alias TipToe.User
  alias TipToe.Model

  @required_fields [:model_id, :user_id]

  schema "followers" do
    belongs_to :user, User
    belongs_to :model, Model
    field :likes_count, :integer, virtual: true
    field :followers_count, :integer, virtual: true

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(%__MODULE__{} = favorite, attrs) do
    favorite
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
