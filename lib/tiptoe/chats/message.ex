defmodule TipToe.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias TipToe.User
  alias TipToe.Room

  # @derive {Jason.Encoder, only: [:id, :text, :user_id, :inserted_at]}

  schema "messages" do
    field :text, :string

    belongs_to :user, User
    belongs_to :room, Room

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [
      :text,
      :user_id,
      :room_id
    ])
    |> validate_required([
      :text,
      :user_id,
      :room_id
    ])
  end
end
