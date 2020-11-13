defmodule TipToeWeb.Resolvers.User do
  alias TipToe.Repo
  import Ecto.Query
  alias TipToe.RepoHelper
  alias TipToe.User
  alias TipToe.Model
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
    models_query =
      from a in Model,
        where: a.user_id == ^user.id,
        order_by: [asc: :stage_name]

    models_by_stage_name = Repo.all(models_query)

    {:ok, %{user | models: models_by_stage_name}}
  end

  def me(_, _) do
    {:error, message: "You Need to login", code: 403}
  end

  def login(%{email: email, password: password}, _resolution) do
    Auth.login(email, password)
  end
end
