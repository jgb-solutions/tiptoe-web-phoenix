defmodule TipToeWeb.GraphQL.Schema do
  use Absinthe.Schema
  import_types(Absinthe.Type.Custom)
  import_types(TipToeWeb.GraphQL.Schema.Types)

  query do
    # Protected Query
    field :me, non_null(:user) do
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
      arg(:page, :integer)
      arg(:take, :integer)
      arg(:model_hash, :string)
      arg(:order_by, list_of(:order_by_input))

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

      resolve(&TipToeWeb.Resolvers.User.find/2)
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
      arg(:page, :integer)
      arg(:take, :integer)
      arg(:order_by, list_of(:order_by_input))

      resolve(&TipToeWeb.Resolvers.Model.paginate/2)
    end

    field :model, :model do
      arg(:hash, non_null(:string))

      resolve(&TipToeWeb.Resolvers.Model.find_by_hash/2)
    end

    field :random_models, :paginate_models do
      arg(:input, non_null(:random_models_input))

      resolve(&TipToeWeb.Resolvers.Model.random_models/2)
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
      resolve(&TipToeWeb.Resolvers.Auth.logout/2)
    end

    # Users
    field :update_user, non_null(:user) do
      arg(:input, non_null(:update_user_input))
      resolve(&TipToeWeb.Resolvers.User.update_user/2)
    end

    field :delete_user, non_null(:delete_user_response) do
      arg(:id, non_null(:id))

      resolve(&TipToeWeb.Resolvers.User.delete_user/2)
    end

    # Photos
    field :add_photo, non_null(:photo) do
      arg(:input, non_null(:photo_input))

      resolve(&TipToeWeb.Resolvers.Photo.add_photo/2)
    end

    field :delete_photo, non_null(:delete_photo_response) do
      arg(:hash, non_null(:string))

      resolve(&TipToeWeb.Resolvers.Photo.delete_photo/2)
    end

    # Categories
    field :add_category, non_null(:category) do
      arg(:input, non_null(:category_input))

      resolve(&TipToeWeb.Resolvers.Category.add_category/2)
    end

    # Models
    field :add_model, non_null(:model) do
      arg(:input, non_null(:model_input))

      resolve(&TipToeWeb.Resolvers.Model.add_model/2)
    end

    field :delete_model, non_null(:delete_model_response) do
      arg(:hash, non_null(:string))

      resolve(&TipToeWeb.Resolvers.Model.delete_model/2)
    end

    field :toggle_like, :toggle_like_response do
      arg(:input, non_null(:toggle_like_input))

      resolve(&TipToeWeb.Resolvers.User.toggle_like/2)
    end

    field :toggle_follow, :toggle_follow_response do
      arg(:input, non_null(:toggle_follow_input))

      resolve(&TipToeWeb.Resolvers.User.toggle_follow/2)
    end

    # Non-protected Mutations
    # Auth
    field :register, :user do
      arg(:input, non_null(:register_input))

      resolve(&TipToeWeb.Resolvers.Auth.register/2)
    end

    field :handle_facebook_connect, non_null(:facebook_login_payload) do
      arg(:code, non_null(:string))

      resolve(&TipToeWeb.Resolvers.Utils.handle_facebook_connect/2)
    end
  end

  subscription do
    # Absinthe.Subscription.publish(TipToeWeb.Endpoint, photo, photo_added: "new_photo")
    field :photo_updates, :photo do
      arg(:topic, non_null(:string))

      # The topic function is used to determine what topic a given subscription
      # cares about based on its arguments. You can think of it as a way to tell the
      # difference between
      # subscription {
      #   photoAdded(repoName: "absinthe-graphql/absinthe") { content }
      # }
      #
      # and
      #
      # subscription {
      #   photoAdded(repoName: "elixir-lang/elixir") { content }
      # }
      #
      # If needed, you can also provide a list of topics:
      #   {:ok, topic: ["absinthe-graphql/absinthe", "elixir-lang/elixir"]}
      config(fn args, _context ->
        {:ok, topic: args.topic}
      end)

      # this tells Absinthe to run any subscriptions with this field every time
      # the :submit_photo mutation happens.
      # It also has a topic function used to find what subscriptions care about
      # this particular photo
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
end
