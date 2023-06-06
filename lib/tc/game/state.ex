defmodule Tc.Game.State do
  alias Tc.Game.Paddle
  alias Tc.Game.Ball

  @moduledoc """
  Keeps track of:
    [:start_time, :time, :player_left, :player_right, :left, :right, :ball, :score]
  """

  @max_paddle_y 75
  @min_paddle_y 0

  @max_ball 98
  @min_ball 0

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
    # |> enforce_boundaries()
    # |> check_collisions()
  end

  def enforce_boundaries(state) do
    %{x: _lx, y: ly} = state.left.pos
    %{x: _rx, y: ry} = state.right.pos
    %{x: bx, y: by} = state.ball.pos

    if ly < @min_paddle_y, do: put_in(state.left.pos.y, @min_paddle_y)
    if ly > @max_paddle_y, do: put_in(state.left.pos.y, @max_paddle_y)

    if ry < @min_paddle_y, do: put_in(state.right.pos.y, @min_paddle_y)
    if ry > @max_paddle_y, do: put_in(state.right.pos.y, @max_paddle_y)

    if bx < @min_ball, do: put_in(state.ball.pos.x, @min_ball)
    if bx > @max_ball, do: put_in(state.ball.pos.x, @max_ball)
    if by < @min_ball, do: put_in(state.ball.pos.y, @min_ball)
    if by > @max_ball, do: put_in(state.ball.pos.y, @max_ball)
  end

  def check_collisions(state) do
    state
  end

end
