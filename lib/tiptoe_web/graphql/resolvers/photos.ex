defmodule TipToeWeb.Resolvers.Photo do
  alias TipToe.Repo
  import Ecto.Query
  alias TipToe.RepoHelper
  alias TipToe.Photo
  alias TipToe.Model
  alias TipToe.Favorite
  alias TipToe.Category
  alias TipToe.Utils

  def paginate(
        %{page: page, take: page_size} = args,
        %{context: %{current_user: user}}
      ) do
    all_my_liked_photos_id = Photo.get_all_liked_photos_id(user)

    query =
      from p in RepoHelper.latest(Photo, :inserted_at),
        full_join: f in Favorite,
        on: f.photo_id == p.id,
        group_by: p.id,
        select_merge: %{
          likes_count: count(f.id)
        }

    query =
      Enum.reduce(Map.take(args, [:random, :model_hash]), query, fn
        {:random, _random}, query ->
          from q in query, order_by: fragment("RANDOM()")

        {:model_hash, model_hash}, query ->
          model = Repo.get_by!(Model, hash: model_hash)

          from p in query,
            where: p.model_id == ^model.id
      end)

    paginated_photos =
      query
      |> RepoHelper.paginate(page: page, page_size: page_size)

    data =
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

    {:ok, data}
  end

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
