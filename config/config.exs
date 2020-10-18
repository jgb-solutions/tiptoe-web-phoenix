# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tip_toe,
  ecto_repos: [TipToe.Repo]

# Configures the endpoint
config :tip_toe, TipToeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pmXOigSHtxhqwd9t9JDen3mg+UEGwofWmI5hyiVPAqZsF92BD2Syybq7FaDtG2fd",
  render_errors: [view: TipToeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TipToe.PubSub,
  live_view: [signing_salt: "Ap4CmHoT"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
