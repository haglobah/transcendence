defmodule TcWeb.GameLive do
  use TcWeb, :live_view

  alias Tc.Game
  # alias Tc.Accounts
  alias TcWeb.Endpoint

  import TcWeb.GameLive.Component

  @moduledoc """
  Main LiveView running the game.
  """
  def render(assigns) do
    ~H"""
    <.canvas view_box="0 0 100 100">
      <% {_lx, ly} = @state.paddle_left.position %>
      <.paddle x={2} y={ ly } />
      <% {_rx, ry} = @state.paddle_right.position %>
      <.paddle x={96} y={ ry } />
      <.ball x={50} y={50} />
      <.score left={0} right={0} />
    </.canvas>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(Game.topic())
    end

    {:ok,
    socket
    |> assign(state: Game.current_state())
    }
  end

  def handle_event("move", %{"key" => key} = _params, socket) do
    new_state = handle_move(key, socket.assigns.current_user, socket.assigns.state)

    {:noreply, assign(socket, state: new_state)}
  end

  def handle_event("stop", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end

  def handle_info({:game_state, state}, socket) do
    IO.puts("\nSTATE:\n")
    IO.inspect(state)
    {:noreply, assign(socket, state: state)}
  end

  defp handle_move("ArrowUp", user, state) when user == state.player_right do
      Game.move_paddle(:paddle_right, :up)
    end
  defp handle_move("ArrowDown", user, state) when user == state.player_right do
      Game.move_paddle(:paddle_right, :down)
    end
  defp handle_move("ArrowUp", user, state) when user == state.player_left do
      IO.puts("here!")
      Game.move_paddle(:paddle_left, :up)
    end
  defp handle_move("ArrowDown", user, state) when user == state.player_left do
      Game.move_paddle(:paddle_left, :down)
    end
  defp handle_move(_, _user, state), do: state
end
