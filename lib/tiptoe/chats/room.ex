defmodule TipToe.Room do
  use Ecto.Schema
  import Ecto.Changeset
  alias TipToe.User
  alias TipToe.Model
  alias TipToe.Message

  schema "rooms" do
    belongs_to :user, User
    belongs_to :model, Model
    has_many :messages, Message

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [])
    |> validate_required([])
  end
end
