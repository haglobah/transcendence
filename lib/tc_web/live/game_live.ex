defmodule TcWeb.GameLive do
  use TcWeb, :live_view

  alias Tc.Game
  import TcWeb.GameLive.Component

  @moduledoc """
  Main LiveView running the game.
  """
  def render(assigns) do
    ~H"""
    <.canvas view_box="0 0 100 100">
      <.paddle x={0} y="40%" />
      <.paddle x={98} y="40%" />
      <.ball x={50} y={50} />
      <.score left={0} right={0} />
    </.canvas>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, initial_state} = Game.init(:t)

    {:ok,
    socket
    |> assign(state: initial_state)
    }
  end
end
