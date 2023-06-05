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

  def mount(%{"game_id" => game_id}, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(Game.tick_topic(game_id))
      Endpoint.subscribe(Game.over_topic(game_id))
    end

    {:ok,
    socket
    |> assign(state: Game.current_state(game_id))
    }
  end

  def handle_event("move", %{"key" => key} = _params, socket) do
    # Don't they don't need return state?
    handle_move(key, socket.assigns.current_user, socket.assigns.state)

    {:noreply, socket}
  end

  def handle_event("stop", %{"key" => key}, socket) do
    # Don't they don't need return state?
    handle_stop(key, socket.assigns.current_user, socket.assigns.state)

    {:noreply, socket}
  end

  def handle_info({:game_state, state}, socket) do
    # IO.inspect(state.paddle_left)
    # IO.inspect(state.paddle_right)
    # IO.inspect(state.ball)
    # IO.inspect(state)
    {:noreply, assign(socket, state: state)}
  end

  def handle_info({:game_over, _state}, socket) do
    {:noreply, assign(socket, title: "Game over")}
  end

  defp handle_stop("ArrowUp", user, state) when user == state.player_right do
      Game.stop_paddle(state.game_id, :paddle_right, state.paddle_right)
    end
  defp handle_stop("ArrowDown", user, state) when user == state.player_right do
      Game.stop_paddle(state.game_id, :paddle_right, state.paddle_right)
    end
  defp handle_stop("ArrowUp", user, state) when user == state.player_left do
      Game.stop_paddle(state.game_id, :paddle_left, state.paddle_left)
    end
  defp handle_stop("ArrowDown", user, state) when user == state.player_left do
      Game.stop_paddle(state.game_id, :paddle_left, state.paddle_left)
    end

  defp handle_move("ArrowUp", user, state) when user == state.player_right do
      Game.move_paddle(state.game_id, :paddle_right, state.paddle_right, :up)
    end
  defp handle_move("ArrowDown", user, state) when user == state.player_right do
      Game.move_paddle(state.game_id, :paddle_right, state.paddle_right, :down)
    end
  defp handle_move("ArrowUp", user, state) when user == state.player_left do
      Game.move_paddle(state.game_id, :paddle_left, state.paddle_left, :up)
    end
  defp handle_move("ArrowDown", user, state) when user == state.player_left do
      Game.move_paddle(state.game_id, :paddle_left, state.paddle_left, :down)
    end
  defp handle_move(_, _user, state), do: state
end
