defmodule Tc.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Tc.Repo,
      TcWeb.Telemetry,
      {Phoenix.PubSub, name: Tc.PubSub},
      TcWeb.Endpoint
      # Start a worker by calling: Tc.Worker.start_link(arg)
      # {Tc.Worker, arg}
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
