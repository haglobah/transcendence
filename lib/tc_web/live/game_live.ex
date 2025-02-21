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
    <%= if @gone do %>
      <p class="my-10 text-center font-mono font-bold text-3xl">This game is already over.</p>
    <% else %>
      <.game_over view_box="0 0 100 100">
        <.paddle x={ @left.x } y={ @left.y } />
        <.paddle x={ @right.x } y={ @right.y } />
        <.ball x={ @ball.x } y={ @ball.y } />
        <.score left={ @score.left } right={ @score.right } />
        <.clock seconds={ 0 } />
      </.game_over>
    <% end %>
    """
  end

  def render(assigns) do
    ~H"""
    <%= if @broken do %>
      <p class="my-10 text-center font-mono font-bold text-3xl">This game does not seem to exist (anymore).</p>
    <% else %>
      <.canvas view_box="0 0 100 100">
        <.paddle x={ @state.left.pos.x } y={ @state.left.pos.y } />
        <.paddle x={ @state.right.pos.x } y={ @state.right.pos.y } />
        <.ball x={ @state.ball.pos.x } y={ @state.ball.pos.y } />
        <.score left={ @state.score.left } right={ @state.score.right } />
        <.clock seconds={ @state.rest_seconds } />
      </.canvas>
    <% end %>
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

    socket = case Game.current_state(game_id) do
      {_, _} ->
        socket
        |> assign(broken: true)
        |> assign(gone: false)
      state ->
        socket
        |> assign(broken: false)
        |> assign(state: state)
        |> assign(gone: false)
    end

    {:ok, socket}
  end

  def handle_params(_params, _uri, %{assigns: assigns} = socket) do
    socket = case assigns[:state] do
     nil -> assign(socket, gone: true)
     _ ->
      socket
      |> assign(left: %{x: assigns.state.left.pos.x, y: assigns.state.left.pos.y})
      |> assign(right: %{x: assigns.state.right.pos.x, y: assigns.state.right.pos.y})
      |> assign(ball: %{x: assigns.state.ball.pos.x, y: assigns.state.ball.pos.y})
      |> assign(score: %{left: assigns.state.score.left, right: assigns.state.score.right})
    end

    {:noreply, socket}
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
    {:noreply, assign(socket, state: state)}
  end

  def handle_info({:game_over, state}, socket) do
    # Patch to the game_over screen
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

  def handle_info(:status_tick, socket) do
    PubSub.broadcast(
      Tc.PubSub,
      Activity.status_topic(),
      {:change, socket.assigns.current_user.id, :online})
    schedule_status_tick()
    {:noreply, socket}
  end

  defp schedule_status_tick(), do: Process.send_after(self(), :status_tick, 1000)

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
