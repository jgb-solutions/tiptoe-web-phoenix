defmodule TipToe.User do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  alias TipToe.Repo
  alias TipToe.User
  alias TipToe.Model
  alias TipToe.Room
  alias TipToe.Favorite

  @default_avatar_url "https://placeimg.com/140/140/any"

  schema "users" do
    field(:name, :string, null: false)
    field(:email, :string, size: 60, unique: true)
    field(:password, :string, size: 60)
    field(:avatar, :string)
    field(:telephone, :string, size: 20)
    field(:admin, :boolean, default: false)
    field(:active, :boolean, default: false)
    field(:password_reset_code, :string)
    field(:first_login, :boolean, default: true)
    field(:img_bucket, :string)
    field(:gender, :string)
    field(:user_type, Ecto.Enum, values: [:consumer, :model])
    field(:avatar_url, :string, virtual: true)

    timestamps()

    has_one(:model, Model, on_replace: :update)
    has_many(:rooms, Room)
    has_many(:favorites, Favorite)
    has_many(:liked_photos, through: [:favorites, :photo])
  end

  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [
      :name,
      :email,
      :password,
      :telephone,
      :avatar,
      :admin,
      :active,
      :first_login,
      :img_bucket,
      :gender,
      :user_type
    ])
    |> validate_required([:name, :email, :password])
    |> unsafe_validate_unique(:email, Repo)
    # |> validate_length(:name, min: 3, max: 10)
    # |> validate_length(:password, min: 5, max: 20)
    |> hash_password()
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password, Bcrypt.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end

  def register(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def get_user!(id) do
    Repo.get!(__MODULE__, id)
  end

  def update_user(%__MODULE__{} = user, attrs) do
    case is_map(attrs.model) do
      true ->
        Repo.preload(user, :model)
        |> changeset(attrs)
        |> put_assoc(:model, attrs.model)

      _ ->
        changeset(user, attrs)
    end
    |> Repo.update()
  end

  def random do
    q =
      from(User,
        order_by: fragment("RANDOM()"),
        limit: 1
      )

    Repo.one(q)
  end

  def make_avatar_url(%__MODULE__{} = user) do
    if user.avatar do
      "https://" <> user.img_bucket <> "/" <> user.avatar
    else
      @default_avatar_url
    end
  end

  def with_avatar_url(%__MODULE__{} = user) do
    %{user | avatar_url: make_avatar_url(user)}
  end
end
