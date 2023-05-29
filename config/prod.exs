import Config

config :tc, TcWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :logger, level: :info

config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Tc.Finch
