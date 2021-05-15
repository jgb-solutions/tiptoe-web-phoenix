defmodule TipToeWeb.Resolvers.Auth do
  alias TipToe.Repo
  alias TipToe.User
  alias TipToe.Model
  import Bcrypt, only: [verify_pass: 2]
  import TipToe.Utils, only: [translate_errors: 1]

  def register(args, _info) do
    input = args[:input] || %{}

    IO.inspect(input)

    case User.register(input) do
      {:ok, user} ->
        if Map.has_key?(input, :model) do
          Model.create(input.model)
        end

        token = generate_token_for(user)

        response = make_response(user, token)

        {:ok, response}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, message: "There was an error", code: 409, errors: translate_errors(changeset)}
    end
  end

  def login(%{input: %{email: email, password: password}}, _info) do
    user = Repo.get_by(User, email: String.downcase(email))

    if user && verify_pass(password, user.password) do
      token = generate_token_for(user)

      response = make_response(user, token)

      {:ok, response}
    else
      {:error, message: "User not found", code: 404}
    end
  end

  def logout(_args, %{context: %{current_user: current_user}}) do
    {:ok, current_user}
  end

  defp generate_token_for(%User{} = user) do
    Phoenix.Token.sign(
      TipToeWeb.Endpoint,
      Application.fetch_env!(:tiptoe, :auth_salt),
      user.id,
      max_age: Application.fetch_env!(:tiptoe, :auth_max_age)
    )
  end

  defp make_response(%User{} = user, token) do
    %{
      data: user |> User.with_avatar_url(),
      token: token
    }
  end
end
