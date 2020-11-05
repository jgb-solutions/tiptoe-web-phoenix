defmodule TipToe.Context do
  @behaviour Plug

  import Plug.Conn

  alias TipToe.Repo
  alias TipToe.User

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  def build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, current_user} <- authorize(token) do
      %{current_user: current_user}
    else
      _ -> %{}
    end
  end

  defp authorize(token) do
    salt = Application.fetch_env!(:TipToe, :auth_salt)
    max_age = Application.fetch_env!(:TipToe, :auth_max_age)

    case Phoenix.Token.verify(TipToeWeb.Endpoint, salt, token, max_age: max_age) do
      {:ok, user_id} ->
        case Repo.get!(User, user_id) do
          nil ->
            {:error, "The user for this token is either deleted or never existed on our servers."}

          user ->
            {:ok, user}
        end

      {:error, _} ->
        {:error, "invalid authorization token"}
    end
  end
end
