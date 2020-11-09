defmodule TipToeWeb.Resolvers.Auth do
  alias TipToe.Repo
  alias TipToe.User
  import Bcrypt, only: [verify_pass: 2]

  def register(args, _resolution) do
    {:ok, User.register(args)}
  end

  def login(%{input: %{email: email, password: password}}, _info) do
    user = Repo.get_by(User, email: String.downcase(email))

    if user && verify_pass(password, user.password) do
      token =
        Phoenix.Token.sign(
          TipToeWeb.Endpoint,
          Application.fetch_env!(:tiptoe, :auth_salt),
          user.id
        )

      response = %{
        data: user |> User.with_avatar_url(),
        token: token
      }

      {:ok, response}
    else
      {:error, message: "User not found", code: 404}
    end
  end

  def logout(_args, %{context: %{current_user: current_user}}) do
    {:ok, current_user}
  end

  def logout(_args, _info) do
    {:error, message: "You Need to login", code: 403}
  end
end
