defmodule TipToe.Model do
  use Ecto.Schema
  import Ecto.Query
  alias TipToe.Repo
  import Ecto.Changeset
  alias TipToe.User
  alias TipToe.Category
  alias TipToe.Photo
  alias TipToe.Room
  alias TipToe.Model
  alias TipToe.Follower
  alias TipToe.Utils

  @default_poster_url "https://img-storage-prod.tiptoe.app/placeholders/model-placeholder.jpg"

  schema "models" do
    field :name, :string, null: false
    field :stage_name, :string, null: false
    field :hash, :integer, unique: true, null: false
    field :poster, :string
    field :img_bucket, :string, null: false
    field :bio, :string
    field :facebook, :string
    field :twitter, :string
    field :instagram, :string
    field :youtube, :string
    field :verified, :boolean, default: false
    field :poster_url, :string, virtual: true
    field :photos_count, :integer, virtual: true
    field :followers_count, :integer, virtual: true
    field :followed_by_me, :boolean, virtual: true
    field :room_with_me, :any, virtual: true

    has_many :photos, Photo
    has_many :followers, Follower
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = model, attrs) do
    model
    |> cast(attrs, [
      :user_id,
      :stage_name,
      :hash,
      :poster,
      :bio,
      :facebook,
      :twitter,
      :instagram,
      :youtube
    ])
    |> validate_required([:stage_name, :hash, :user_id])
  end

  def create(attrs \\ %{}) do
    %__MODULE__{
      hash: Utils.get_hash(__MODULE__)
    }
    |> changeset(attrs)
    |> Repo.insert()
  end

  def random do
    query =
      from Model,
        order_by: fragment("RANDOM()"),
        limit: 1

    Repo.one(query)
  end

  def make_poster_url(%__MODULE__{} = model) do
    if model.poster do
      "https://" <> model.img_bucket <> "/" <> model.poster
    else
      @default_poster_url
    end
  end

  def with_poster_url(%__MODULE__{} = model) do
    %{model | poster_url: make_poster_url(model)}
  end

  def with_followed_by_user(%__MODULE__{} = model, all_my_followed_models) do
    %{
      model
      | followed_by_me: model.id in all_my_followed_models
    }
  end

  def get_all_followed_models_id(%User{} = user) do
    models_followed_by_me_query =
      from f in "followers",
        where: f.user_id == ^user.id,
        select: f.model_id

    Repo.all(models_followed_by_me_query)
  end

  def with_followers_count(%__MODULE__{} = model) do
    followers_query =
      from f in "followers",
        where: f.model_id == ^model.id,
        select: count(f.id)

    followers_count = Repo.one(followers_query)

    %{
      model
      | followers_count: followers_count
    }
  end

  def with_room_for_user(%__MODULE__{} = model, %User{} = user) do
    room_query =
      from r in Room,
        where: r.user_id == ^user.id,
        where: r.model_id == ^model.id,
        limit: 1

    room = Repo.one(room_query)

    %{
      model
      | room_with_me: room
    }
  end
end
