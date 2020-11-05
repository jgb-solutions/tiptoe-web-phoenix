defmodule TipToe.Model do
  use Ecto.Schema
  import Ecto.Query
  alias TipToe.Repo
  import Ecto.Changeset
  alias TipToe.User
  alias TipToe.Category
  alias TipToe.Photo
  alias TipToe.Model

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

    timestamps()

    has_many :photos, Photo
    belongs_to :user, User
  end

  @doc false
  def changeset(model, attrs) do
    model
    |> cast(attrs, [])
    |> validate_required([])
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
end
