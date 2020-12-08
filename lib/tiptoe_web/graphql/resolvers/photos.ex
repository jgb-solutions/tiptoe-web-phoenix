defmodule TipToeWeb.Resolvers.Photo do
  alias TipToe.Repo
  import Ecto.Query
  alias TipToe.RepoHelper
  alias TipToe.Photo
  alias TipToe.Model
  alias TipToe.Favorite
  alias TipToe.Category
  alias TipToe.Utils
  alias Size
  # alias TipToe.Cache

  def paginate(args, %{context: %{current_user: user}}) do
    page = args[:page] || 1
    page_size = args[:take] || 20
    model_hash = args[:model_hash]

    # _key = "photos_page_" <> to_string(page)

    q =
      from p in RepoHelper.latest(Photo, :inserted_at),
        preload: [:model, :category],
        full_join: f in Favorite,
        on: f.photo_id == p.id,
        group_by: p.id,
        select_merge: %{
          like_count: count(f.id)
          # liked_by_me: f.user_id == ^user.id
        }

    q =
      case(model_hash) do
        nil ->
          q

        _ ->
          model = Repo.get_by!(Model, hash: model_hash)

          from p in q,
            where: p.model_id == ^model.id
      end

    paginated_photos =
      q
      |> RepoHelper.paginate(page: page, page_size: page_size)

    data =
      Map.put(
        paginated_photos,
        :data,
        Enum.map(
          paginated_photos.data,
          &Photo.with_url(&1)
        )
      )

    {:ok, data}
  end

  def paginate(_args, _resolution),
    do: {
      :error,
      message: "You Need to login", code: 401
    }

  def related_photos(%{input: %{hash: hash, take: take}}, _resolution) do
    q =
      from t in Photo,
        preload: [:model],
        where: t.hash != ^hash,
        limit: ^take,
        order_by: fragment("RANDOM()")

    photos_with_url =
      Repo.all(q)
      |> Enum.map(&Photo.with_url(&1))

    {:ok, photos_with_url}
  end

  def find_by_hash(args, _resolution) do
    q =
      from t in Photo,
        where: t.hash == ^args.hash,
        preload: [:model, :category]

    case Repo.one(q) do
      %Photo{} = photo ->
        {
          :ok,
          photo
          |> Photo.with_url()
        }

      nil ->
        {:error, message: "Photo Not Found", code: 404}
    end
  end

  def photos_by_category(args, _resolution) do
    %{
      take: take,
      slug: slug,
      order_by: order_by_list
    } = args

    page = args[:page] || 1

    case Repo.get_by(Category, slug: slug) do
      %Category{} = category ->
        q =
          from t in Photo,
            where: t.category_id == ^category.id,
            preload: [:model],
            order_by: ^Utils.make_order_by_list(order_by_list)

        paginated_photos = RepoHelper.paginate(q, page: page, page_size: take)

        paginated_photos_with_poster_url =
          Map.put(
            paginated_photos,
            :data,
            Enum.map(paginated_photos.data, &Photo.with_url(&1))
          )

        {:ok, paginated_photos_with_poster_url}

      nil ->
        {:error, message: "Photo Not Found", code: 404}
    end
  end

  def add_photo(args, %{context: %{current_user: current_user}}) do
    {:ok, "Photo added"}
  end

  def create(_args, _info) do
    {:error, "Not Authorized"}
  end
end
