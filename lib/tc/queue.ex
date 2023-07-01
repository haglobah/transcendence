defmodule Tc.Queue do
  use GenServer

  alias Tc.Game
  alias Phoenix.PubSub

  @name :game_queue

  def topic() do
    "in_queue"
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def enqueue(user) do
    GenServer.call @name, %{enq: user}
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

  def handle_call(%{enq: user}, _from, state) do
    case length(state) do
      1 ->
        left = hd(state)
        right = user
        game_id = Nanoid.generate()
        DynamicSupervisor.start_child(Tc.GameSupervisor, {Game, {left, right, game_id}})
        PubSub.broadcast(Tc.PubSub, topic(), {:queue, left, right, game_id})
        {:reply, [], []}
      0 ->
        state = [user | state]
        {:reply, state, state}
    end
  end

  def handle_call({:priv_game, {left, right}}, _from, state) do
    game_id = Nanoid.generate()
    DynamicSupervisor.start_child(Tc.GameSupervisor, {Game, {left, right, game_id}})
    PubSub.broadcast(Tc.PubSub, topic(), {:queue, left, right, game_id})

    {:reply, state, state}
  end

  def handle_call(:current, _from, state) do
    {:reply, state, state}
  end
end
