defmodule TipToe.Room do
  use Ecto.Schema
  import Ecto.Changeset
  alias TipToe.User
  alias TipToe.Model
  alias TipToe.Message

  @inputs [
    :user_id,
    :model_id
  ]

  schema "rooms" do
    belongs_to :user, User
    belongs_to :model, Model
    has_many :messages, Message

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, @inputs)
    |> validate_required(@inputs)
  end
end
