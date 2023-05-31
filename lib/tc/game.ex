defmodule Tc.Game do
  use GenServer

  alias Tc.Game.State

  @fps 60
  @tick_ms div(1000, @fps)

  @game_round_length 20

  @moduledoc """
  A named GenServer which runs the Pong game.

  Dispatches a `tick` message to itself every #{@tick_ms} milliseconds,
  which then runs an update of the world state (thus at ~#{@fps} frames per second).
  """

  @impl true
  def init(_) do
    Process.send_after(self(), :tick, @tick_ms)
    # subscibe to the velocity topic?
    {:ok, State.new()}
  end

  @impl true
  def handle_info(:tick, state) do
    Process.send_after(self(), :tick, @tick_ms)
    state = tick(state)
    {:noreply, state}
  end

  defp tick(state) do
    new_time = System.monotonic_time()
    delta_time = new_time - state.time
    total_time = new_time - state.start_time
    rest_seconds = @game_round_length - System.convert_time_unit(total_time, :native, :second)

    game_state = State.tick(state.game_state, delta_time)

    if rest_seconds < 0 do
      Phoenix.PubSub.broadcast(Tc.PubSub, "game/over", {"game/over", %{}})
      game_state
    else
      Phoenix.PubSub.broadcast(Tc.PubSub, "game/tick", {"game/tick", %{game_state: game_state}})

      %{state | time: new_time, game_state: game_state}
    end
  end
end
