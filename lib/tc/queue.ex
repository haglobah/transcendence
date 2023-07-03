defmodule Tc.Queue do
  use GenServer

  alias Tc.Game
  alias Phoenix.PubSub

  @name :game_queue

  def topic() do
    "in_queue"
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{fast: [], normal: []}, name: @name)
  end

  def enqueue(user, fast?) do
    GenServer.call @name, %{enq: user, fast?: fast?}
  end

  def current() do
    GenServer.call @name, :current
  end

  def start_private_game(current_user, other_user) do
    GenServer.call @name, {:priv_game, {current_user, other_user}}
  end

  def init(queue_at_start) do
    {:ok, queue_at_start}
  end

  def handle_call(%{enq: user, fast?: fast?}, _from, state) do
    case fast? do
      true -> start_game(user, fast?, state.fast, state)
      false -> start_game(user, fast?, state.normal, state)
    end
  end

  def handle_call({:priv_game, {left, right}}, _from, state) do
    game_id = Nanoid.generate()
    DynamicSupervisor.start_child(Tc.GameSupervisor, {Game, {left, right, game_id, false}})
    PubSub.broadcast(Tc.PubSub, topic(), {:queue, left, right, game_id})

    {:reply, state, state}
  end

  def handle_call(:current, _from, state) do
    {:reply, state, state}
  end

  defp start_game(user, fast?, queue, state) do
    queue = case queue do
      [left] ->
        right = user
        if left == right do
          [left]
        else
          game_id = Nanoid.generate()
          DynamicSupervisor.start_child(Tc.GameSupervisor, {Game, {left, right, game_id, fast?}})
          PubSub.broadcast(Tc.PubSub, topic(), {:queue, left, right, game_id})
          []
        end
      [] ->
        [user]
    end

    state = case fast? do
      true -> %{state | fast: queue}
      false -> %{state | normal: queue}
    end

    {:reply, state, state}
  end
end
