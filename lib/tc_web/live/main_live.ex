defmodule TcWeb.MainLive do
  use TcWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>
      The Pong Game
    </h1>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
