defmodule TcWeb.GameLive do
  use TcWeb, :live_view

  alias Tc.Game
  alias TcWeb.Endpoint
  alias Tc.Activity
  alias Phoenix.PubSub

  import TcWeb.GameLive.Component

  @moduledoc """
  Main LiveView running the game.
  """
  def render(%{live_action: :game_over} = assigns) do
    ~H"""
    <div>
      <h2 class="text-center font-mono">
        <p><b>About the game</b>:</p>
        <p>Players use paddles to hit the ball back and forth.</p>
        <p>Points are earned when one fails to return the ball.</p><br>
        <p><b>How to play</b>:</p>
        <p>Players move their paddle <b>up</b> and <b>down</b> using <b>↑</b> and <b>↓</b> on their keyboards.</p><br>
      </h2>
    </div>
    <.game_over view_box="0 0 100 100">
      <.paddle x={ @left.x } y={ @left.y } />
      <.paddle x={ @right.x } y={ @right.y } />
      <.ball x={ @ball.x } y={ @ball.y } />
      <.score left={ @score.left } right={ @score.right } />
      <.clock seconds={ 0 } />
    </.game_over>
    """
  end

  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-center font-mono">
        <p><b>About the game</b>:</p>
        <p>Players use paddles to hit the ball back and forth.</p>
        <p>Points are earned when one fails to return the ball.</p><br>
        <p><b>How to play</b>:</p>
        <p>Players move their paddle <b>up</b> and <b>down</b> using <b>↑</b> and <b>↓</b> on their keyboards.</p>
        <.button phx-click="pause" class="my-4">
          Pause Game
        </.button>
      </h2>
    </div>
    <.canvas view_box="0 0 100 100">
      <.paddle x={ @state.left.pos.x } y={ @state.left.pos.y } />
      <.paddle x={ @state.right.pos.x } y={ @state.right.pos.y } />
      <.ball x={ @state.ball.pos.x } y={ @state.ball.pos.y } />
      <.score left={ @state.score.left } right={ @state.score.right } />
      <.clock seconds={ @state.rest_seconds } />
    </.canvas>
    """
  end

  def mount(_params, _session, %{assigns: %{live_action: :game_over}} = socket) do
    {:ok, socket}
  end

  def mount(%{"game_id" => game_id}, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(Game.tick_topic(game_id))
      Endpoint.subscribe(Game.over_topic(game_id))
    end

    schedule_status_tick()

    {:ok,
    socket
    |> assign(state: Game.current_state(game_id))
    }
  end

  def handle_params(_params, _uri, %{assigns: assigns} = socket) do
    {:noreply, socket
      |> assign(left: %{x: assigns.state.left.pos.x, y: assigns.state.left.pos.y})
      |> assign(right: %{x: assigns.state.right.pos.x, y: assigns.state.right.pos.y})
      |> assign(ball: %{x: assigns.state.ball.pos.x, y: assigns.state.ball.pos.y})
      |> assign(score: %{left: assigns.state.score.left, right: assigns.state.score.right})
    }
  end

  def handle_event("move", %{"key" => key} = _params, socket) do
    handle_move(key, socket.assigns.current_user, socket.assigns.state)

    {:noreply, socket}
  end

  def handle_event("stop", %{"key" => key}, socket) do
    handle_stop(key, socket.assigns.current_user, socket.assigns.state)

    {:noreply, socket}
  end

  def handle_event("pause", _params, socket) do
    handle_pause(socket.assigns.current_user, socket.assigns.state)

    {:noreply, socket}
  end

  def handle_info({:game_state, state}, socket) do
    {:noreply, assign(socket, state: state)}
  end

  def handle_info({:game_over, state}, socket) do
    {:noreply, push_patch(socket, to: "/game/#{state.game_id}/game_over")}
  end

  def handle_info(:status_tick, %{assigns: %{state: state}} = socket) do
    PubSub.broadcast(
      Tc.PubSub,
      Activity.status_topic(),
      {:change, socket.assigns.current_user.id, {:in_game, state.game_id}})
    schedule_status_tick()
    {:noreply, socket}
  end

  defp schedule_status_tick(), do: Process.send_after(self(), :status_tick, 1000)

  defp handle_pause(_user, state), do: Game.pause(state.game_id, state)

  defp handle_stop("ArrowUp", user, state) when user == state.player_right do
      Game.stop_paddle(state.game_id, :right, state.right)
    end
  defp handle_stop("ArrowDown", user, state) when user == state.player_right do
      Game.stop_paddle(state.game_id, :right, state.right)
    end
  defp handle_stop("ArrowUp", user, state) when user == state.player_left do
      Game.stop_paddle(state.game_id, :left, state.left)
    end
  defp handle_stop("ArrowDown", user, state) when user == state.player_left do
      Game.stop_paddle(state.game_id, :left, state.left)
    end
  defp handle_stop(_, _user, state), do: state

  defp handle_move("ArrowUp", user, state) when user == state.player_right do
      Game.move_paddle(state.game_id, :right, state.right, :up)
    end
  defp handle_move("ArrowDown", user, state) when user == state.player_right do
      Game.move_paddle(state.game_id, :right, state.right, :down)
    end
  defp handle_move("ArrowUp", user, state) when user == state.player_left do
      Game.move_paddle(state.game_id, :left, state.left, :up)
    end
  defp handle_move("ArrowDown", user, state) when user == state.player_left do
      Game.move_paddle(state.game_id, :left, state.left, :down)
    end
  defp handle_move(_, _user, state), do: state
end
