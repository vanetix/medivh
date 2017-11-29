# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :medivh, MedivhWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "6DiMkFqtncdBo94guNUq7Rdrs0/69jixV1XEXhBX3DafcrKJNxwHC1vWGEif4DFs",
  render_errors: [view: MedivhWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Medivh.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

try do
  import_config "#{Mix.env}.secret.exs"
rescue
  _ -> IO.puts("No secrets configuration found for #{Mix.env}")
end
