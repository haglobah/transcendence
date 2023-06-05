defmodule Tc.Game.State do
  alias Tc.Game.Paddle
  alias Tc.Game.Ball

  @moduledoc """
  Keeps track of:
    [:start_time, :time, :player_left, :player_right, :paddle_left, :paddle_right, :ball, :score]
  """

  defstruct [:game_id,
    :start_time, :time,
    :player_left, :player_right,
    :paddle_left, :paddle_right,
    :ball, :score]

  def new(player_left, player_right, game_id) do
    start_time = System.monotonic_time()
    %__MODULE__{
      game_id: game_id,
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

  def tick(state, new_time, dt) do
    %{state | time: new_time,
              # ball: Ball.move(state.ball, dt),
              paddle_left: Paddle.move(state.paddle_left, dt),
              paddle_right: Paddle.move(state.paddle_right, dt),
            }
  end

end
