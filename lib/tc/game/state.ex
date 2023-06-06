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
    :start_time, :time,
    :player_left, :player_right,
    :left, :right,
    :ball, :score]

  def new(player_left, player_right, game_id) do
    start_time = System.monotonic_time()
    %__MODULE__{
      game_id: game_id,
      start_time: start_time,
      time: start_time,
      player_left: player_left,
      player_right: player_right,
      left: Paddle.new(),
      right: Paddle.new(),
      ball: Ball.new(),
      score: %{left: 0, right: 0},
    }
  end

  def tick(state, new_time, dt) do
    %{state | time: new_time,
              ball: Ball.move(state.ball, dt),
              left: Paddle.move(state.left, dt),
              right: Paddle.move(state.right, dt),
            }
    |> enforce_borders()
    # |> check_collisions()
  end

  def enforce_borders(state) do
    state
    |> enforce_left(state.left, %{min: @min_paddle_y, max: @max_paddle_y})
    |> enforce_right(state.right, %{min: @min_paddle_y, max: @max_paddle_y})
    |> enforce(state.ball, %{min: @min_ball, max: @max_ball})
  end

  def enforce_left(state, %Paddle{} = paddle, %{min: min, max: max}) do
    cond do
      paddle.pos.y < min -> put_in(state.left.pos.y, min)
      paddle.pos.y > max -> put_in(state.left.pos.y, max)
      true -> state
    end
  end
  def enforce_right(state, %Paddle{} = paddle, %{min: min, max: max}) do
    cond do
      paddle.pos.y < min -> put_in(state.right.pos.y, min)
      paddle.pos.y > max -> put_in(state.right.pos.y, max)
      true -> state
    end
  end

  def enforce(state, %Ball{} = ball, %{min: min, max: max}) do

    new_state =
      cond do
        ball.pos.y < min -> put_in(state.ball.pos.y, min)
        ball.pos.y > max -> put_in(state.ball.pos.y, max)
        true -> state
      end
    cond do
      ball.pos.x < min -> put_in(new_state.ball.pos.x, min)
      ball.pos.x > max -> put_in(new_state.ball.pos.x, max)
      true -> new_state
    end
  end

  def check_collisions(state) do
    state
  end

end
