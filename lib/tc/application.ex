defmodule Tc.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Repo
      Tc.Repo,
      # Start the Telemetry Supervisor
      TcWeb.Telemetry,
      # Start the PubSub System
      {Phoenix.PubSub, name: Tc.PubSub},
      # Start the Endpoint (http/https)
      TcWeb.Endpoint,
      # Start a worker by calling: Tc.Worker.start_link(arg)
      # {Tc.Worker, arg}
      # Start the App state
      Tc.Game,
    ]

    opts = [strategy: :one_for_one, name: Tc.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    TcWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
