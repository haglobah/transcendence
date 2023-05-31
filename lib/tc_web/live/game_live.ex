defmodule TcWeb.GameLive do
  use TcWeb, :live_view

  alias Tc.Game
  import TcWeb.GameLive.Component

  alias TcWeb.Endpoint

  @moduledoc """
  Main LiveView running the game.
  """
  def render(assigns) do
    ~H"""
    <.canvas view_box="0 0 100 100">
      <.paddle x={2} y={37} />
      <.paddle x={96} y={37} />
      <.ball x={50} y={50} />
      <.score left={0} right={0} />
    </.canvas>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(Game.topic())
    end
    {:ok, initial_state} = Game.init(:t)

    {:ok,
    socket
    |> assign(state: initial_state)
    }
  end

  def handle_event("move", %{"key" => key} = _params, socket) do
    new_state = handle_move(key, socket)

    {:noreply, assign(socket, state: new_state)}
  end

  def handle_event("stop", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end

  def handle_info({:game_state, state}, socket) do
    IO.puts("\n\n\nSTATE:\n\n\n")
    IO.inspect(state)
    {:noreply, assign(socket, state: state)}
  end

  defp handle_move(key, socket) do
    case key do
      "ArrowUp" -> Game.move_paddle(:paddle_right, :up)
      "ArrowDown" -> Game.move_paddle(:paddle_right, :down)
      _ -> socket
    end
  end
end
