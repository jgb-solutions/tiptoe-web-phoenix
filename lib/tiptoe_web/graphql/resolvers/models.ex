defmodule TipToeWeb.Resolvers.Model do
  alias TipToe.Repo
  import Ecto.Query
  alias TipToe.RepoHelper
  alias TipToe.Model
  alias TipToe.Photo

  def paginate(args, _resolution) do
    page = args[:page] || 1
    page_size = args[:take] || 20

    q =
      from RepoHelper.latest(Model),
        preload: []

    paginated_models =
      q
      |> RepoHelper.paginate(page: page, page_size: page_size)

    paginated_models_with_poster_url = %{
      paginated_models
      | data: Enum.map(paginated_models.data, &Model.with_poster_url(&1))
    }

    {:ok, paginated_models_with_poster_url}
  end

  def find_by_hash(args, _resolution) do
    photos_query =
      from t in Photo,
        order_by: [desc: t.inserted_at]

    q =
      from a in Model,
        where: a.hash == ^args.hash,
        preload: [
          photos: ^photos_query
        ],
        limit: 1

    case Repo.one(q) do
      %Model{} = model ->
        model_with_cover_url = model |> Model.with_poster_url()

        data = %{
          model_with_cover_url
          | photos:
              Enum.map(model_with_cover_url.photos, fn photo ->
                photo
                |> Photo.with_url()
              end)
        }

        {:ok, data}

      nil ->
        {:error, message: "Model Not Found", code: 404}
    end
  end
end
