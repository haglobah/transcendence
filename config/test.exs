import Config

config :tc, Tc.Repo, pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :warn

config :tc, Tc.Mailer, adapter: Swoosh.Adapters.Test
