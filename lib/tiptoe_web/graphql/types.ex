defmodule TipToeWeb.GraphQL.Schema.Types do
  use Absinthe.Schema.Notation
  alias Absinthe.Blueprint.Schema
  # Object
  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
    field :avatar_url, :string
    field :telephone, :string
    field :admin, :boolean
    field :active, :boolean
    field :first_login, :boolean
    field :photos, list_of(:photo)
    field :models, list_of(:model)
    field :inserted_at, :naive_datetime
    field :updated_at, :naive_datetime
  end

  object :model do
    field :id, :id
    field :name, non_null(:string)
    field :stage_name, non_null(:string)
    field :hash, non_null(:integer)
    field :poster_url, :string
    field :bio, :string
    field :photos, list_of(:photo)
    field :user, :user
    field :facebook_url, :string
    field :twitter_url, :string
    field :instagram_url, :string
    field :youtube_url, :string
    field :inserted_at, non_null(:naive_datetime)
    field :updated_at, non_null(:naive_datetime)
  end

  object :photo do
    field :id, :id
    field :caption, non_null(:string)
    field :hash, non_null(:integer)
    field :url, :string
    field :featured, :boolean
    field :detail, :string
    field :category, non_null(:category)
    field :model, non_null(:model)
    field :user, :user
    field :like_count, non_null(:integer)
    field :inserted_at, non_null(:naive_datetime)
    field :updated_at, non_null(:naive_datetime)
  end

  object :category do
    field :id, :id
    field :name, non_null(:string)
    field :slug, non_null(:string)
    field :photos, :paginate_photos
    field :inserted_at, non_null(:naive_datetime)
    field :updated_at, non_null(:naive_datetime)
  end

  object :upload_url do
    field :signed_url, non_null(:string)
    field :filename, non_null(:string)
  end

  object :login_payload do
    field :data, non_null(:user)
    field :token, non_null(:string)
  end

  # input_object
  input_object :upload_url_input do
    field :name, non_null(:string)
    field :bucket, non_null(:string)
    field :public, :boolean
    field :attachment, :boolean
  end

  input_object :order_by_input do
    field :field, non_null(:string)
    field :order, non_null(:string)
  end

  object :facebook_login_url do
    field :url, non_null(:string)
  end

  object :logout_response do
    field :success, :boolean
  end

  object :search_results do
    field :photos, list_of(:photo)
    field :models, list_of(:model)
  end

  object :paginate do
    field :pagination_info, :pagination_info
  end

  object :paginate_models do
    import_fields(:paginate)
    field :data, list_of(:model)
  end

  object :paginate_photos do
    import_fields(:paginate)
    field :data, list_of(:photo)
  end

  object :paginate_users do
    import_fields(:paginate)
    field :data, list_of(:user)
  end

  object :pagination_info do
    field :current_page, :integer
    field :per_page, :integer
    field :total, :integer
    field :total_pages, :integer
    field :has_more_pages, :boolean
  end

  input_object :photo_input do
    field :caption, non_null(:string)
    field :uri, non_null(:string)
    field :detail, :string
    field :lyrics, :string
    field :audioFileSize, non_null(:integer)
    field :modelId, non_null(:integer)
    field :categoryId, non_null(:integer)
    field :img_bucket, non_null(:string)
  end

  input_object :category_input do
    field :name, non_null(:string)
  end

  input_object :add_photo_to_album_input do
    field :album_id, non_null(:string)
    field :photo_hash, non_null(:string)
    field :photo_number, non_null(:integer)
  end

  input_object :model_input do
    field :name, non_null(:string)
    field :stage_name, non_null(:string)
    field :poster, :string
    field :img_bucket, non_null(:string)
    field :bio, :string
    field :facebook, :string
    field :twitter, :string
    field :instagram, :string
    field :youtube, :string
  end

  input_object :album_input do
    field :title, non_null(:string)
    field :release_year, non_null(:integer)
    field :model_id, non_null(:integer)
    field :cover, non_null(:string)
    field :detail, :string
    field :img_bucket, non_null(:string)
  end

  input_object :register_input do
    field :name, non_null(:string)
    field :email, non_null(:string)
    field :password, non_null(:string)
    field :telephone, :string
  end

  input_object :update_user_input do
    field :id, :id
    field :name, :string
    field :email, :string
    field :password, :string
    field :telephone, :string
    field :avatar, :string
    field :img_bucket, :string
  end

  input_object :login_input do
    field :email, non_null(:string)
    field :password, non_null(:string)
  end

  object :delete_album_response do
    field :success, :boolean
  end

  object :delete_photo_response do
    field :success, :boolean
  end

  object :delete_model_response do
    field :success, :boolean
  end

  object :delete_user_response do
    field :success, :boolean
  end

  object :facebook_login_payload do
    field :data, :user
    field :token, non_null(:string)
  end

  input_object :related_photos_input do
    field :hash, non_null(:string)
    field :take, non_null(:integer)
  end

  input_object :random_models_input do
    field :hash, non_null(:string)
    field :take, non_null(:integer)
  end

  input_object :random_albums_input do
    field :hash, non_null(:string)
    field :take, non_null(:integer)
  end

  input_object :view_input do
    field :hash, non_null(:string)
    field :type, non_null(:string)
  end

  # Enum
  # enum :sort_order do
  #   value(:asc, as: "ASC")
  #   value(:desc, as: "DESC")
  # end

  enum(:sort_order, values: [:asc, :desc])
end
