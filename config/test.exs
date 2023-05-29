import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

config :tc, Tc.Repo, pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :warn

config :tc, Tc.Mailer, adapter: Swoosh.Adapters.Test
