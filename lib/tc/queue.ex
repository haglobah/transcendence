defmodule Tc.Queue do
  use GenServer

  alias Tc.Game
  alias Tc.Accounts
  alias TcWeb.Endpoint

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

  def init(queue_at_start) do
    {:ok, queue_at_start}
  end

  def handle_call(%{enq: user}, _from, state) do
    case length(state) do
      1 ->
        player_left = hd(state)
        player_right = user
        route = "aaa"
        DynamicSupervisor.start_child(Tc.GameSupervisor, {Game, {player_left, player_right}})
        Phoenix.PubSub.broadcast(Tc.PubSub, topic(), {player_left, player_right, route})
        {:reply, [], []}
      0 ->
        state = [user | state]
        {:reply, state, state}
    end
  end

  def handle_call(:current, _from, state) do
    {:reply, state, state}
  end
end
