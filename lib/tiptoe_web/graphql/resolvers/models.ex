defmodule TipToeWeb.Resolvers.Model do
  alias TipToe.Repo
  import Ecto.Query
  alias TipToe.RepoHelper
  alias TipToe.Model
  alias TipToe.Follower

  def paginate(args, _resolution) do
    page = args[:page] || 1
    page_size = args[:take] || 20

    q =
      from RepoHelper.latest(Model),
        preload: [:user]

    paginated_models =
      q
      |> RepoHelper.paginate(page: page, page_size: page_size)

    paginated_models_with_poster_url = %{
      paginated_models
      | data: Enum.map(paginated_models.data, &Model.with_poster_url(&1))
    }

    {:ok, paginated_models_with_poster_url}
  end

  def find_by_hash(args, %{context: %{current_user: user}}) do
    followers_subquery =
      from f in Follower,
        group_by: f.id

    # select_merge: %{
    #   followers_count: count(f.id)
    # }

    q =
      from m in Model,
        where: m.hash == ^args.hash,
        left_join: p in assoc(m, :photos),
        left_join: f in subquery(followers_subquery),
        on: f.model_id == m.id,
        group_by: m.id,
        limit: 1,
        select_merge: %{
          photos_count: count(p.id),
          # followers_count: count(f.id)
          follower: f
        }

    case Repo.one(q) do
      %Model{} = model ->
        all_my_followed_models_id = Model.get_all_followed_models_id(user)
        model_with_poster_url = model |> Model.with_poster_url()

        model =
          Model.with_followed_by_user(
            model_with_poster_url,
            all_my_followed_models_id
          )

        {:ok, model}

      nil ->
        {:error, message: "Model Not Found", code: 404}
    end
  end
end
