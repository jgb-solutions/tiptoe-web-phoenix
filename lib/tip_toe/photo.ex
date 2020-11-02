defmodule TipToe.Photo do
  use Ecto.Schema
  import Ecto.Query
  alias TipToe.Repo
  import Ecto.Changeset
  alias TipToe.User
  alias TipToe.Category
  alias TipToe.Photo
  alias TipToe.Model

  @default_url "https://img-storage-prod.tiptoe.app/placeholders/photo-placeholder.jpg"

  schema "photos" do
    field :caption, :string, null: false
    field :hash, :integer, unique: true, null: false
    field :uri, :string, null: false
    field :img_bucket, :string, null: false
    field :featured, :boolean, default: false
    field :detail, :string
    field :like_count, :integer, default: 0
    field :publish, :boolean, default: true
    field :url, :string, virtual: true

    timestamps()

    belongs_to :user, User
    belongs_to :model, Model
    belongs_to :category, Category
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
      :user_id,
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
      :user_id,
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
    if photo do
      "https://" <> photo.img_bucket <> "/" <> photo.uri
    else
      @default_url
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
end
