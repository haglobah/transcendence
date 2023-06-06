defmodule Tc.Game.State do
  alias Tc.Game.Paddle
  alias Tc.Game.Ball

  @moduledoc """
  Keeps track of:
    [:start_time, :time, :player_left, :player_right, :left, :right, :ball, :score]
  """

  @min_paddle_y 0
  @max_paddle_y 75

  @min_ball 0
  @max_ball 98

  defstruct [:game_id,
    :start_time, :time, :rest_seconds,
    :player_left, :player_right,
    :left, :right,
    :ball, :score]

  def new(player_left, player_right, game_id, game_length) do
    start_time = System.monotonic_time()
    %__MODULE__{
      game_id: game_id,
      start_time: start_time,
      time: start_time,
      rest_seconds: game_length,
      player_left: player_left,
      player_right: player_right,
      left: Paddle.new(2),
      right: Paddle.new(96),
      ball: Ball.new(),
      score: %{left: 0, right: 0},
    }
  end

  def tick(state, new_time, dt, rest_seconds) do
    %{state | time: new_time,
              rest_seconds: rest_seconds,
              ball: Ball.move(state.ball, dt),
              left: Paddle.move(state.left, dt),
              right: Paddle.move(state.right, dt),
            }
    |> enforce_borders()
    |> score_points()
    |> collisions()
  end

  def enforce_borders(state) do
    %{state |
        left: Paddle.enforce(state.left, %{min: @min_paddle_y, max: @max_paddle_y}),
        right: Paddle.enforce(state.right, %{min: @min_paddle_y, max: @max_paddle_y}),
        ball: Ball.enforce(state.ball, %{min: @min_ball, max: @max_ball}),
    }
  end

  def score_points(state) do
    cond do
      state.ball.pos.x == @min_ball -> update_in(state.score.right, fn p -> p + 1 end)
      state.ball.pos.x == @max_ball -> update_in(state.score.left, fn p -> p + 1 end)
      true -> state
    end
  end

  def collisions(state) do
    new_ball =
      state.ball
      |> Ball.collision(%{min: @min_ball, max: @max_ball})
      |> Ball.collision(state, %{west_left_edge: 0, west_right_edge: 94})

    %{state | ball: new_ball}
  end

end
