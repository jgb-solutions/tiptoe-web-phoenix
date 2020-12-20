defmodule TipToeWeb.Resolvers.Model do
  alias TipToe.Repo
  import Ecto.Query
  alias TipToe.RepoHelper
  alias TipToe.Model
  alias TipToe.Follower

  @page 1
  @page_size 20

  def paginate(args, _resolution) do
    page = args[:page] || @page
    page_size = args[:take] || @page_size

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
    q =
      from m in Model,
        where: m.hash == ^args.hash,
        left_join: p in assoc(m, :photos),
        group_by: m.id,
        limit: 1,
        select_merge: %{
          photos_count: count(p.id)
        }

    case Repo.one(q) do
      %Model{} = model ->
        all_my_followed_models_id = Model.get_all_followed_models_id(user)
        model_with_poster_url = model |> Model.with_poster_url()

        model_with_followed_by_user =
          Model.with_followed_by_user(
            model_with_poster_url,
            all_my_followed_models_id
          )

        model_with_followers_count = Model.with_followers_count(model_with_followed_by_user)
        model_with_room_for_user = Model.with_room_for_user(model_with_followers_count, user)

        {:ok, model_with_room_for_user}

      nil ->
        {:error, message: "Model Not Found", code: 404}
    end
  end
end
