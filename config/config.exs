# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :poll, Poll.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "Jq+svnnwcM+cxDRg9r5eyi9sz+rkrs98ArNIT7UKM+2rALUz3tdjJbLqhWbSteZR",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Poll.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :ueberauth, Ueberauth,
  providers: [
  	facebook: { Ueberauth.Strategy.Facebook, [] }
  ]

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :plug, :mimes, %{"application/vnd.api+json" => ["json-api"]}