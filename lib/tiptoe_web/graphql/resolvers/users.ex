defmodule TipToeWeb.Resolvers.User do
  alias TipToe.Repo
  import Ecto.Query
  alias TipToe.RepoHelper
  alias TipToe.User
  alias TipToe.Model
  alias TipToe.Room
  alias TipToe.Photo
  alias TipToe.Favorite
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

    query =
      from p in Photo,
        join: f in Favorite,
        on: f.photo_id == p.id,
        where: f.user_id == ^user.id,
        preload: [:model],
        group_by: p.id,
        order_by: [desc: :inserted_at],
        select_merge: %{like_count: count(f.id)}

    paginated_photos =
      query
      |> RepoHelper.paginate(page: page, page_size: page_size)

    photo_list =
      Map.put(
        paginated_photos,
        :data,
        Enum.map(
          paginated_photos.data,
          fn photo ->
            photo_with_url = Photo.with_url(photo)

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

  # def tag_product(product, %{tag: tag_attrs} = attrs) do
  #   tag = create_or_find_tag(tag_attrs)

  #   product
  #   |> Ecto.build_assoc(:taggings)
  #   |> Tagging.changeset(attrs)
  #   |> Ecto.Changeset.put_assoc(:tag, tag)
  #   |> Repo.insert()
  # end

  # defp create_or_find_tag(%{name: "" <> name} = attrs) do
  #   %Tag{}
  #   |> Tag.changeset(attrs)
  #   |> Repo.insert()
  #   |> case do
  #     {:ok, tag} -> tag
  #     _ -> Repo.get_by(Tag, name: name)
  #   end
  # end

  # defp create_or_find_tag(_), do: nil

  # def delete_tag_from_product(product, tag) do
  #   Repo.find_by(Tagging, product_id: product.id, tag_id: tag.id)
  #   |> case do
  #     %Tagging{} = tagging -> Repo.delete(tagging)
  #     nil -> {:ok, %Tagging{}}
  #   end
  # end
end
