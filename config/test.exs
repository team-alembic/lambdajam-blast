use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :blast, BlastWeb.Endpoint,
  http: [port: 4002],
  server: false

config :blast, ecto_repos: []

# Print only warnings and errors during test
config :logger, level: :warn
