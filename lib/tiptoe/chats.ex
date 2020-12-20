defmodule TipToe.Chats do
  import Ecto.Query, warn: false
  alias TipToe.Repo
  alias TipToe.Message
  alias TipToe.Room

  def list_room_messages(room_id) do
    query =
      from m in Message,
        where: m.room_id == ^room_id,
        order_by: [desc: :inserted_at],
        limit: 20,
        preload: [:user]

    Repo.all(query)
  end

  def create_room(%{input: %{model_id: model_id}} = _args, %{context: %{current_user: user}}) do
    query =
      from r in Room,
        where: r.model_id == ^model_id,
        where: r.user_id == ^user.id,
        limit: 1

    case Repo.one(query) do
      nil ->
        room_changeset =
          %Room{}
          |> Room.changeset(%{model_id: model_id, user_id: user.id})

        case Repo.insert(room_changeset) do
          {:error, _changeset} -> {:error, message: "Room could not be created", code: 503}
          {:ok, room} -> {:ok, room}
        end

      room ->
        {:ok, room}
    end
  end

  def get_message!(id), do: Repo.get!(Message, id)

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert!()
    |> Repo.preload(:user)
  end

  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
