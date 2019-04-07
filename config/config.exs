# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :blast, ecto_repos: []

# Configures the endpoint
config :blast, BlastWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VB3trJje1/klbu5vAtGoDsKEuEG6SVv34tfzul7txK6CfMZSPl3k2R5QcBWGe0U7",
  render_errors: [view: BlastWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Blast.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
     signing_salt: "funtimes!"
   ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
