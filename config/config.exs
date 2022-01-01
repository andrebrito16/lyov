# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :cgnaflightsapi,
  ecto_repos: [Cgnaflightsapi.Repo]

# Configures the endpoint
config :cgnaflightsapi, CgnaflightsapiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Umsl9Dx/FjUM9hUGq8/RLJTyimLtnfd1XPi5lkA4izd30YRyxv3YkQjlXiRKQOpq",
  render_errors: [view: CgnaflightsapiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Cgnaflightsapi.PubSub,
  live_view: [signing_salt: "gclG1eNe"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
