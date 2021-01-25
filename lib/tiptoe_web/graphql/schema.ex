defmodule TipToeWeb.GraphQL.Schema do
  use Absinthe.Schema
  import_types(Absinthe.Type.Custom)
  import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 3]

  alias TipToeWeb.Schema.Middleware.Authenticate
  alias TipToe.{Accounts, Models}

  query do
    # Protected Query
    field :me, non_null(:user) do
      middleware(Authenticate)
      resolve(&TipToeWeb.Resolvers.User.me/2)
    end

    field :upload_url, non_null(:upload_url) do
      arg(:input, non_null(:upload_url_input))
      resolve(&TipToeWeb.Resolvers.Utils.upload_url/2)
    end

    # Non-protected query
    field :login, :login_payload do
      arg(:input, non_null(:login_input))
      resolve(&TipToeWeb.Resolvers.Auth.login/2)
    end

    # Photos
    @desc "Get all photos"
    field :photos, :paginate_photos do
      arg(:page, type: :integer, default_value: 1)
      arg(:take, type: :integer, default_value: 20)
      arg(:model_hash, type: :string, default_value: nil)
      arg(:random, type: :boolean, default_value: false)
      arg(:order_by, list_of(:order_by_input))
      middleware(Authenticate)
      resolve(&TipToeWeb.Resolvers.Photo.paginate/2)
    end

    field :photos_by_category, :paginate_photos do
      arg(:page, :integer)
      arg(:take, :integer)
      arg(:order_by, list_of(:order_by_input))
      arg(:slug, non_null(:string))

      resolve(&TipToeWeb.Resolvers.Photo.photos_by_category/2)
    end

    field :favorite_photos, :paginate_photos do
      arg(:page, :integer)
      arg(:take, :integer)
      arg(:order_by, list_of(:order_by_input))

      resolve(&TipToeWeb.Resolvers.User.favorite_photos/2)
    end

    field :related_photos, list_of(:photo) do
      arg(:input, non_null(:related_photos_input))

      resolve(&TipToeWeb.Resolvers.Photo.related_photos/2)
    end

    field :photo, :photo do
      arg(:hash, non_null(:string))

      resolve(&TipToeWeb.Resolvers.Photo.find_by_hash/2)
    end

    # Users
    field :users, :paginate_users do
      arg(:page, :integer)
      arg(:take, :integer)
      arg(:order_by, list_of(:order_by_input))

      resolve(&TipToeWeb.Resolvers.User.paginate/2)
    end

    field :user, :user do
      arg(:id, non_null(:id))

      # resolve(&TipToeWeb.Resolvers.User.find/2)
    end

    # Categories
    field :categories, list_of(:category) do
      resolve(&TipToeWeb.Resolvers.Category.all/2)
    end

    field :category, :category do
      arg(:slug, non_null(:string))

      resolve(&TipToeWeb.Resolvers.Category.find_by_slug/2)
    end

    # Models
    field :models, :paginate_models do
      arg(:order_by, list_of(:order_by_input))
      arg(:page, type: :integer, default_value: 1)
      arg(:take, type: :integer, default_value: 20)
      arg(:random, type: :boolean, default_value: false)
      arg(:order_by, list_of(:order_by_input))
      middleware(Authenticate)
      resolve(&TipToeWeb.Resolvers.Model.paginate/2)
    end

    field :model, :model do
      arg(:hash, non_null(:string))

      resolve(&TipToeWeb.Resolvers.Model.find_by_hash/2)
    end

    field :random_models, :paginate_models do
      arg(:input, non_null(:random_models_input))

      # resolve(&TipToeWeb.Resolvers.Model.random_models/2)
    end

    field :search, non_null(:search_results) do
      arg(:query, non_null(:string))

      resolve(&TipToeWeb.Resolvers.Utils.search/2)
    end
  end

  mutation do
    # Protected Mutations
    @desc "Create a user"
    field :register, type: :user do
      arg(:name, non_null(:string))
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      arg(:telephone, :string)

      resolve(&TipToeWeb.Resolvers.Auth.register/2)
    end

    # Auth
    field :logout, non_null(:logout_response) do
      middleware(Authenticate)
      resolve(&TipToeWeb.Resolvers.Auth.logout/2)
    end

    # Users
    field :update_user, non_null(:user) do
      arg(:input, non_null(:update_user_input))
      middleware(Authenticate)
      # resolve(&TipToeWeb.Resolvers.User.update_user/2)
    end

    field :delete_user, non_null(:delete_user_response) do
      arg(:id, non_null(:id))
      middleware(Authenticate)
      # resolve(&TipToeWeb.Resolvers.User.delete_user/2)
    end

    # Photos
    field :add_photo, non_null(:photo) do
      arg(:input, non_null(:photo_input))
      middleware(Authenticate)
      resolve(&TipToeWeb.Resolvers.Photo.add_photo/2)
    end

    field :delete_photo, non_null(:delete_photo_response) do
      arg(:hash, non_null(:string))
      middleware(Authenticate)
      # resolve(&TipToeWeb.Resolvers.Photo.delete_photo/2)
    end

    # Categories
    field :add_category, non_null(:category) do
      arg(:input, non_null(:category_input))
      middleware(Authenticate)
      # resolve(&TipToeWeb.Resolvers.Category.add_category/2)
    end

    # Models
    field :add_model, non_null(:model) do
      arg(:input, non_null(:model_input))
      middleware(Authenticate)
      # resolve(&TipToeWeb.Resolvers.Model.add_model/2)
    end

    field :delete_model, non_null(:delete_model_response) do
      arg(:hash, non_null(:string))
      middleware(Authenticate)
      # resolve(&TipToeWeb.Resolvers.Model.delete_model/2)
    end

    field :toggle_like, :toggle_like_response do
      arg(:input, non_null(:toggle_like_input))
      middleware(Authenticate)
      resolve(&TipToeWeb.Resolvers.User.toggle_like/2)
    end

    field :toggle_follow, :toggle_follow_response do
      arg(:input, non_null(:toggle_follow_input))
      middleware(Authenticate)
      resolve(&TipToeWeb.Resolvers.User.toggle_follow/2)
    end

    field :create_room, non_null(:room) do
      arg(:input, non_null(:create_room_input))
      middleware(Authenticate)
      resolve(&TipToe.Chats.create_room/2)
    end

    # Non-protected Mutations
    # Auth
    field :register, :user do
      arg(:input, non_null(:register_input))

      resolve(&TipToeWeb.Resolvers.Auth.register/2)
    end

    field :handle_facebook_connect, non_null(:facebook_login_payload) do
      arg(:code, non_null(:string))

      # resolve(&TipToeWeb.Resolvers.Utils.handle_facebook_connect/2)
    end
  end

  subscription do
    # Absinthe.Subscription.publish(TipToeWeb.Endpoint, photo, photo_added: "new_photo")
    field :photo_updates, :photo do
      arg(:topic, non_null(:string))

      config(fn args, _context ->
        {:ok, topic: args.topic}
      end)

      trigger(:submit_photo,
        topic: fn photo ->
          photo.repository_name
        end
      )

      resolve(fn photo, _, _ ->
        # this function is often not actually necessary, as the default resolver
        # for subscription functions will just do what we're doing here.
        # The point is, subscription resolvers receive whatever value triggers
        # the subscription, in our case a photo.
        {:ok, photo}
      end)
    end
  end

  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
    field :avatar_url, :string
    field :telephone, :string
    field :admin, :boolean
    field :active, :boolean
    field :first_login, :boolean

    field :liked_photos, list_of(:photo) do
      arg(:limit, type: :integer, default_value: 10)
      resolve(dataloader(Accounts, :liked_photos, args: %{scope: :user}))
    end

    field :rooms, list_of(:room) do
      arg(:limit, type: :integer)
      resolve(dataloader(Accounts, :rooms, args: %{scope: :user}))
    end

    field :model, :model, resolve: dataloader(Accounts)
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
    field :photos_count, :integer
    field :followers_count, :integer
    field :followed_by_me, :boolean
    field :room_with_me, :room
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
    field :category, :category, resolve: dataloader(Models)
    field :model, :model, resolve: dataloader(Models)
    field :user, :user
    field :likes_count, :integer
    field :liked_by_me, :boolean
    field :inserted_at, non_null(:naive_datetime)
    field :updated_at, non_null(:naive_datetime)
  end

  object :message do
    field :id, :id
    field :text, :string
    field :user, :user, resolve: dataloader(Accounts)
    field :inserted_at, non_null(:naive_datetime)
    field :updated_at, non_null(:naive_datetime)
  end

  object :room do
    field :id, :id

    field :chat_user, :chat_user do
      resolve(&Accounts.chat_user/3)
    end

    field :model, :model, resolve: dataloader(Accounts)

    field :messages, list_of(:message) do
      arg(:limit, type: :integer, default_value: 1)
      resolve(dataloader(Accounts, :messages, args: %{scope: :room}))
    end

    field :inserted_at, non_null(:naive_datetime)
    field :updated_at, non_null(:naive_datetime)
  end

  object :chat_user do
    field :id, :id
    field :name, :string
    field :avatar_url, :string
    field :model_hash, :string
    field :type, :string
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

  object :paginate_messages do
    import_fields(:paginate)
    field :data, list_of(:message)
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

  object :toggle_like_response do
    field :success, :boolean
  end

  object :toggle_follow_response do
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

  input_object :toggle_like_input do
    field :photo_id, non_null(:string)
  end

  input_object :toggle_follow_input do
    field :model_id, non_null(:string)
  end

  input_object :create_room_input do
    field :model_id, non_null(:string)
  end

  enum(:sort_order, values: [:asc, :desc])

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Accounts, Accounts.datasource())
      |> Dataloader.add_source(Models, Models.datasource())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
