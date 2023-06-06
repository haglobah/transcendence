defmodule Tc.Game.Paddle do

  @movement_speed 1/30000000

  defstruct [:pos, :velocity, :width, :height]

  def new(x) do
    %__MODULE__{
      pos: %{x: x, y: 37},
      velocity: %{x: 0, y: 0},
      width: 2,
      height: 25,
    }
  end

  def enforce(paddle, %{min: min, max: max}) do
    cond do
      paddle.pos.y < min -> put_in(paddle.pos.y, min)
      paddle.pos.y > max -> put_in(paddle.pos.y, max)
      true -> paddle
    end
  end

  def put_velocity(paddle, %{x: vx, y: vy}) do
    update_in(paddle.velocity, fn %{x: _vx, y: _vy} -> %{x: vx, y: vy} end)
  end

  def move(paddle, dt) do
    update_in(paddle.pos, fn %{x: x, y: y} ->
      %{x: _vx, y: vy} = paddle.velocity
      # x2 = x + vx * dt * @movement_speed
      y2 = y + vy * dt * @movement_speed

      %{x: x, y: y2}
    end)
  end
end
