defmodule TipToe.Accounts do
  import Ecto.Query
  alias TipToe.Repo

  alias TipToe.{Room, Photo, Model, User, Message}

  def chat_user(room, _params, %{context: %{current_user: current_user}} = _resolution) do
    model_query =
      from m in Model,
        where: m.user_id == ^current_user.id,
        limit: 1

    chat_user =
      case Repo.one(model_query) do
        nil ->
          room_with_model = room |> Repo.preload(:model)

          %{
            id: room_with_model.model.id,
            name: room_with_model.model.stage_name,
            avatar_url: Model.make_poster_url(room_with_model.model),
            type: "model",
            model_hash: room_with_model.model.hash
          }

        _model ->
          room_with_user = room |> Repo.preload(:user)

          %{
            id: room_with_user.user.id,
            name: room_with_user.user.name,
            avatar_url: User.make_avatar_url(room.user),
            type: "user"
          }
      end

    {:ok, chat_user}
  end

  # Dataloader
  def datasource() do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

  def query(Photo, %{limit: limit, scope: :user}) do
    Photo
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
  end

  def query(Room, %{scope: :user, limit: limit}) do
    Room
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
  end

  def query(Message, %{scope: :room, limit: limit}) do
    Message
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
  end

  def query(queryable, _) do
    queryable
  end
end
