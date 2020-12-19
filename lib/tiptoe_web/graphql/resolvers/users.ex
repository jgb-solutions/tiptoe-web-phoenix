defmodule TipToeWeb.Resolvers.User do
  alias TipToe.Repo
  import Ecto.Query
  alias TipToe.Room
  alias TipToe.User
  alias TipToe.Model
  alias TipToe.Photo
  alias TipToe.Message
  alias TipToe.Favorite
  alias TipToe.Follower
  alias TipToe.RepoHelper
  alias TipToeWeb.Resolvers.Auth

  @page 1
  @page_size 20

  def paginate(args, _resolution) do
    page = args[:page] || @page
    page_size = args[:take] || @page_size

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

  def favorite_photos(args, %{context: %{current_user: user}}) do
    page = args[:page] || 1
    page_size = args[:take] || 20

    all_my_liked_photos_id = Photo.get_all_liked_photos_id(user)

    favorite_query =
      from f in Favorite,
        join: p in assoc(f, :photo),
        where: f.user_id == ^user.id,
        preload: [photo: :model],
        order_by: [desc: :inserted_at],
        group_by: f.id,
        select_merge: %{likes_count: count(f.id)}

    paginated_favorites =
      favorite_query
      |> RepoHelper.paginate(page: page, page_size: page_size)

    # Get photo list from favorites
    photo_list =
      Map.put(
        paginated_favorites,
        :data,
        Enum.map(
          paginated_favorites.data,
          fn favorite ->
            photo_with_url = %{
              Photo.with_url(favorite.photo)
              | likes_count: favorite.likes_count
            }

            Photo.with_liked_by_user(photo_with_url, all_my_liked_photos_id)
          end
        )
      )

    {:ok, photo_list}
  end

  def toggle_like(
        %{input: %{photo_id: photo_id}} = _args,
        %{context: %{current_user: user}}
      ) do
    query =
      from f in Favorite,
        where: f.photo_id == ^photo_id,
        where: f.user_id == ^user.id,
        limit: 1

    status =
      case Repo.one(query) do
        nil ->
          f_changeset =
            %Favorite{}
            |> Favorite.changeset(%{photo_id: photo_id, user_id: user.id})

          case Repo.insert(f_changeset) do
            {:ok, _} ->
              true

            {:error, _} ->
              false
          end

        favorite ->
          case Repo.delete(favorite) do
            {:ok, _} ->
              photo = Repo.get!(Photo, photo_id)

              Absinthe.Subscription.publish(
                TipToeWeb.Endpoint,
                Photo.with_url(photo),
                photo_updates: "photo_unliked"
              )

              true

            {:error, _} ->
              false
          end
      end

    {:ok, %{success: status}}
  end

  def toggle_follow(
        %{input: %{model_id: model_id}} = _args,
        %{context: %{current_user: user}}
      ) do
    query =
      from f in Follower,
        where: f.model_id == ^model_id,
        where: f.user_id == ^user.id,
        limit: 1

    status =
      case Repo.one(query) do
        nil ->
          f_changeset =
            %Follower{}
            |> Follower.changeset(%{model_id: model_id, user_id: user.id})

          case Repo.insert(f_changeset) do
            {:ok, _} ->
              true

            {:error, _} ->
              false
          end

        follow ->
          case Repo.delete(follow) do
            {:ok, _} ->
              true

            {:error, _} ->
              false
          end
      end

    {:ok, %{success: status}}
  end
end
