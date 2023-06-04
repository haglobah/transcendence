defmodule Tc.Game.State do
  alias Tc.Game.Paddle
  alias Tc.Game.Ball

  @moduledoc """
  Keeps track of:
    [:start_time, :time, :player_left, :player_right, :paddle_left, :paddle_right, :ball, :score]
  """

  defstruct [:id, :start_time, :time, :player_left, :player_right, :paddle_left, :paddle_right, :ball, :score]

  def new(player_left, player_right, game_id) do
    start_time = System.monotonic_time()
    %__MODULE__{
      id: game_id,
      start_time: start_time,
      time: start_time,
      player_left: player_left,
      player_right: player_right,
      paddle_left: Paddle.new(),
      paddle_right: Paddle.new(),
      ball: Ball.new(),
      score: {0, 0},
    }
  end

  def tick(state, dt) do
    state
    |> Ball.move(state.ball, dt)
    |> Paddle.move(state.paddle_left, dt)
    |> Paddle.move(state.paddle_right, dt)
  end

end
