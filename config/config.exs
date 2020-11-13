# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tiptoe,
  ecto_repos: [TipToe.Repo]

# Configures the endpoint
config :tiptoe, TipToeWeb.Endpoint,
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

config :ex_aws,
  # System.get_env("AWS_ACCESS_KEY_ID"),
  access_key_id: "AR6K1TTHKLAGMSA1J9OU",
  # System.get_env("AWS_SECRET_ACCESS_KEY"),
  secret_access_key: "2J6HqYidF7na9yklSpQBtz8bggtXToeFaDV1XnWZ",
  s3: [
    scheme: "https://",
    host: "s3.us-west-1.wasabisys.com",
    region: "us-west-1"
    # bucket:
  ]

config :tiptoe,
  auth_salt: "qr0k5WcsL2+XO2g44Wf135AA2EB7QWZVm7TTcbmUiewIkCa9V408YselnPunPMNo",
  auth_max_age: 6 * 30 * 24 * 60 * 60

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
