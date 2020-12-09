defmodule TipToe.Photo do
  use Ecto.Schema
  import Ecto.Query
  alias TipToe.Repo
  import Ecto.Changeset
  alias TipToe.Category
  alias TipToe.Photo
  alias TipToe.Model
  alias TipToe.User
  alias TipToe.Favorite

  @default_avatar_url "https://img-storage-prod.tiptoe.app/placeholders/photo-placeholder.jpg"

  schema "photos" do
    field :caption, :string, null: false
    field :hash, :integer, unique: true, null: false
    field :uri, :string, null: false
    field :img_bucket, :string, null: false
    field :featured, :boolean, default: false
    field :detail, :string
    field :like_count, :integer, virtual: true
    field :liked_by_me, :boolean, virtual: true
    field :publish, :boolean, default: true
    field :url, :string, virtual: true

    belongs_to :model, Model
    belongs_to :category, Category
    has_many :favorites, Favorite
    has_many :users_whole_liked, through: [:favorites, :user]

    timestamps()
  end

  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [
      :caption,
      :hash,
      :uri,
      :img_bucket,
      :featured,
      :detail,
      :model_id,
      :category_id,
      :like_count,
      :publish
    ])
    |> validate_required([
      :caption,
      :hash,
      :uri,
      :img_bucket,
      :model_id,
      :category_id
    ])
  end

  def random do
    query =
      from Photo,
        # order_by: fragment("RANDOM()"),
        limit: 1

    Repo.one(query)
  end

  def make_url(%__MODULE__{} = photo) do
    if photo.uri do
      "https://" <> photo.img_bucket <> "/" <> photo.uri
    else
      @default_avatar_url
    end
  end

  def with_url(%__MODULE__{} = photo) do
    photo_with_url = %{
      photo
      | url: make_url(photo)
    }

    case Map.has_key?(photo, :model) do
      true -> Map.put(photo_with_url, :model, Model.with_poster_url(photo.model))
      _ -> photo_with_url
    end
  end

  def with_liked_by_user(%__MODULE__{} = photo, all_my_liked_photos) do
    %{
      photo
      | liked_by_me: photo.id in all_my_liked_photos
    }
  end

  def get_all_liked_photos_id(%User{} = user) do
    photos_liked_by_me_query =
      from f in "favorites",
        where: f.user_id == ^user.id,
        select: f.photo_id

    Repo.all(photos_liked_by_me_query)
  end
end
