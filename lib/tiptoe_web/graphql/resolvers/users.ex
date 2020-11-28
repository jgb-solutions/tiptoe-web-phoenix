defmodule TipToeWeb.Resolvers.User do
  alias TipToe.Repo
  import Ecto.Query
  alias TipToe.RepoHelper
  alias TipToe.User
  alias TipToe.Model
  alias TipToe.Room
  alias TipToe.Message
  alias TipToeWeb.Resolvers.Auth

  def paginate(args, _resolution) do
    page = args[:page] || 1
    page_size = args[:take] || 20

    q =
      from RepoHelper.latest(User),
        preload: [:model]

    paginated_users =
      q
      |> RepoHelper.paginate(page: page, page_size: page_size)

    paginated_users_with_avatar_url =
      Map.put(
        paginated_users,
        :data,
        Enum.map(paginated_users.data, &User.with_avatar_url(&1))
      )

    {:ok, paginated_users_with_avatar_url}
  end

  def me(_, %{context: %{current_user: user}}) do
    model_query =
      from m in Model,
        where: m.user_id == ^user.id,
        limit: 1

    user_model = Repo.one(model_query)

    messages_query =
      from m in Message,
        order_by: [desc: m.inserted_at],
        limit: 10

    rooms_query =
      from r in Room,
        where: r.user_id == ^user.id,
        order_by: [desc: r.inserted_at],
        preload: [messages: ^messages_query]

    room_with_chat_user_query =
      case user_model do
        nil ->
          model_query =
            from m in Model,
              preload: [:user]

          from r in rooms_query,
            preload: [model: ^model_query]

        _model ->
          from r in rooms_query,
            preload: [:user]
      end

    rooms = Repo.all(room_with_chat_user_query)

    rooms =
      case user_model do
        nil ->
          Enum.map(rooms, fn room ->
            IO.inspect(room.model)

            Map.put(
              room,
              :chat_user,
              %{
                id: room.model.id,
                name: room.model.stage_name,
                avatar_url: Model.make_poster_url(room.model),
                type: "model",
                model_hash: room.model.hash
              }
            )
          end)

        _model ->
          Enum.map(rooms, fn room ->
            Map.put(
              room,
              :chat_user,
              %{
                id: room.user.id,
                name: room.user.name,
                avatar_url: User.make_avatar_url(room.user),
                type: "user"
              }
            )
          end)
      end

    {:ok, %{user | rooms: rooms}}
  end

  def me(_, _) do
    {:error, message: "You Need to login", code: 403}
  end

  def login(%{email: email, password: password}, _resolution) do
    Auth.login(email, password)
  end
end
