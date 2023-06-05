defmodule Tc.Game do
  use GenServer

  alias Tc.Game.State
  alias Tc.Game.Paddle
  alias Phoenix.PubSub

  @registry :game_registry

  @fps 30
  @tick_ms div(1000, @fps)

  @max_round_length 90

  @moduledoc """
  A named GenServer which runs the Pong game.

  Dispatches a `tick` message to itself every #{@tick_ms} milliseconds,
  which then runs an update of the world state (thus at ~#{@fps} frames per second).
  """

  # External API (runs in the client)

  def topic(game_id) do
    "#{game_id}:move"
  end
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
    {:ok, State.new(left, right, game_id)}
  end

  # Implementation (runs in the GenServer Process)

  def handle_call(:current, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:unmove, which, paddle}, _from, state) do
    new_state = %{state | which => Paddle.put_velocity(paddle, {0, 0})}
    {:reply, new_state, new_state}
  end

  def handle_call({:move, which, paddle, direction}, _from, state) do
    case direction do
      :up -> make_change(state, which, paddle, {0, -1})
      :down -> make_change(state, which, paddle, {0, 1})
    end
  end

  defp make_change(state, which, paddle, {_dx, _dy} = change) do
    IO.inspect(paddle)
    new_paddle = Paddle.put_velocity(paddle, change)
    IO.inspect(new_paddle)
    new_state = %{state | which => new_paddle}
    IO.puts("AFTER\n")
    IO.inspect(new_state)
    # PubSub.broadcast(Tc.PubSub, topic(state.game_id), {:game_state, new_state})
    {:reply, new_state, new_state}
  end

  def handle_info(:tick, state) do
    {rest_seconds, new_state} = next(state)

    if rest_seconds < 0 do
      PubSub.broadcast(Tc.PubSub, over_topic(new_state.game_id), {:game_over, new_state})
      {:stop, :game_over, new_state}
    else
      PubSub.broadcast(Tc.PubSub, tick_topic(new_state.game_id), {:game_state, new_state})
      schedule_tick()
      {:noreply, state}
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

    new_state = State.tick(state, new_time, delta_time)

    {rest_seconds, new_state}
  end

  defp schedule_tick(), do: Process.send_after(self(), :tick, @tick_ms)
  defp via_tuple(game_id), do: {:via, Registry, {@registry, game_id}}

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
