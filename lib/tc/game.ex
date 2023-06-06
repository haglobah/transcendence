defmodule Tc.Game do
  use GenServer, restart: :transient

  alias Tc.Game.State
  alias Tc.Game.Paddle
  alias Phoenix.PubSub

  @registry :game_registry

  @fps 60
  @tick_ms div(1000, @fps)

  @max_round_length 3

  @moduledoc """
  A named GenServer which runs the Pong game.

  Dispatches a `tick` message to itself every #{@tick_ms} milliseconds,
  which then runs an update of the world state (thus at ~#{@fps} frames per second).
  """

  # External API (runs in the client)

  def over_topic(game_id) do
    "#{game_id}:over"
  end
  def tick_topic(game_id) do
    "#{game_id}:tick"
  end

  def start_link({_, _, game_id} = init_game) do
    GenServer.start_link(__MODULE__, init_game, name: via_tuple(game_id))
  end

  def current_state(game_id) do
    game_id |> via_tuple() |> GenServer.call(:current)
  end

  def move_paddle(game_id, which, paddle, direction) do
    game_id |> via_tuple() |> GenServer.call({:move, which, paddle, direction})
  end
  def stop_paddle(game_id, which, paddle) do
    game_id |> via_tuple() |> GenServer.call({:unmove, which, paddle})
  end

  def init({left, right, game_id}) do
    schedule_tick()
    {:ok, State.new(left, right, game_id, @max_round_length)}
  end

  # Implementation (runs in the GenServer Process)

  def handle_call(:current, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:unmove, which, paddle}, _from, state) do
    new_state = %{state | which => Paddle.put_velocity(paddle, %{x: 0, y: 0})}
    {:reply, new_state, new_state}
  end

  def handle_call({:move, which, paddle, direction}, _from, state) do
    case direction do
      :up -> make_change(state, which, paddle, %{x: 0, y: -1})
      :down -> make_change(state, which, paddle, %{x: 0, y: 1})
    end
  end

  defp make_change(state, which, paddle, change) do
    new_state = %{state | which => Paddle.put_velocity(paddle, change)}
    # PubSub.broadcast(Tc.PubSub, topic(state.game_id), {:game_state, new_state})
    {:reply, new_state, new_state}
  end

  def handle_info(:tick, state) do
    {rest_seconds, new_state} = next(state)

    if rest_seconds < 0 do
      PubSub.broadcast(Tc.PubSub, over_topic(new_state.game_id), {:game_over, new_state})
      :timer.sleep(2000)
      {:stop, :normal, new_state}
    else
      PubSub.broadcast(Tc.PubSub, tick_topic(new_state.game_id), {:game_state, new_state})
      schedule_tick()
      {:noreply, new_state}
    end
  end

  # def terminate(:normal, _state) do
  #   # Write important game stats to DB

  #   # Return nothing?
  # end

  defp next(state) do
    new_time = System.monotonic_time()
    delta_time = new_time - state.time
    total_time = new_time - state.start_time
    rest_seconds = @max_round_length - System.convert_time_unit(total_time, :native, :second)

    new_state = State.tick(state, new_time, delta_time, rest_seconds)

    # IO.inspect(state.ball)
    # IO.inspect(state.left)
    # IO.inspect(state.right)

    {rest_seconds, new_state}
  end

  defp schedule_tick(), do: Process.send_after(self(), :tick, @tick_ms)
  defp via_tuple(game_id), do: {:via, Registry, {@registry, game_id}}
end
