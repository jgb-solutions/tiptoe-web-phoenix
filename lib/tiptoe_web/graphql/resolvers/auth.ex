defmodule TipToeWeb.Resolvers.Auth do
  alias TipToe.Repo
  alias TipToe.User
  import Bcrypt, only: [verify_pass: 2]

  def register(args, _info) do
    input = args[:input] || %{}

    case User.register(input) do
      {:ok, user} ->
        token = generate_token_for(user)
        response = make_response(user, token)

        {:ok, response}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)

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

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  defp translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(TipToeWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(TipToeWeb.Gettext, "errors", msg, opts)
    end
  end
end
