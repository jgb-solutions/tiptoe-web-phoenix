defmodule TipToeWeb.Resolvers.Photo do
  alias TipToe.Repo
  import Ecto.Query
  alias TipToe.RepoHelper
  alias TipToe.Photo
  alias TipToe.Category
  alias TipToe.Utils
  alias Size
  alias TipToe.Cache

  def paginate(args, _resolution) do
    page = args[:page] || 1
    page_size = args[:take] || 20

    key = "photos_page_" <> to_string(page)

    q =
      from RepoHelper.latest(Photo, :inserted_at),
        preload: [:model, :category]

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

  def related_photos(%{input: %{hash: hash, take: take}}, _resolution) do
    q =
      from t in Photo,
        preload: [:model, :album],
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
        preload: [:album, :model, :category]

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
