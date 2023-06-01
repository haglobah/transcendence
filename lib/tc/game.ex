defmodule Tc.Game do
  use GenServer

  alias Tc.Game.Queue
  alias Tc.Game.State
  alias Tc.Game.Paddle
  alias Phoenix.PubSub

  @name :game_server

  @fps 60
  @tick_ms div(1000, @fps)

  # @game_round_length 20

  @moduledoc """
  A named GenServer which runs the Pong game.

  Dispatches a `tick` message to itself every #{@tick_ms} milliseconds,
  which then runs an update of the world state (thus at ~#{@fps} frames per second).
  """

  # External API (runs in the client)

  def topic() do
    "move"
  end

  def start_link(_opts) do
    players = Queue.get()
    GenServer.start_link(__MODULE__, players, name: @name)
  end

  def current_state() do
    GenServer.call @name, :current
  end

  def move_paddle(paddle, direction) do
    GenServer.call @name, {:move, paddle, direction}
  end

  def init({player_left, player_right}) do
    # tick?
    {:ok, State.new(player_left, player_right)}
  end

  # Implementation (runs in the GenServer Process)

  def handle_call(:current, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:move, paddle, direction}, _from, state) do
    case direction do
      :up -> make_change(state, paddle, {0, -1})
      :down -> make_change(state, paddle, {0, 1})
    end
  end

  defp make_change(state, paddle, {_dx, _dy} = change) do
    new_state =
      Paddle.change_position(state, paddle, change)
    PubSub.broadcast(Tc.PubSub, topic(), {:game_state, new_state})
    {:reply, new_state, new_state}
  end


  # @impl true
  # def init(_) do
  #   Process.send_after(self(), :tick, @tick_ms)
  #   # subscibe to the velocity topic?
  #   {:ok, State.new()}
  # end

  # @impl true
  # def handle_info(:tick, state) do
  #   Process.send_after(self(), :tick, @tick_ms)
  #   state = tick(state)
  #   {:noreply, state}
  # end

  # defp tick(state) do
  #   new_time = System.monotonic_time()
  #   delta_time = new_time - state.time
  #   total_time = new_time - state.start_time
  #   rest_seconds = @game_round_length - System.convert_time_unit(total_time, :native, :second)

  #   game_state = State.tick(state.game_state, delta_time)

  #   if rest_seconds < 0 do
  #     Endpoint.broadcast(Tc.PubSub, "game/over", %{})
  #     game_state
  #   else
  #     Endpoint.broadcast(Tc.PubSub, "game/tick", %{game_state: game_state})

  #     %{state | time: new_time, game_state: game_state}
  #   end
  # end
end
