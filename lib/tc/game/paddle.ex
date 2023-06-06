defmodule Tc.Game.Paddle do

  @movement_speed 1/3000000000

  defstruct [:position, :velocity, :width, :height]

  def new do
    %__MODULE__{
      position: {0, 37},
      velocity: {0, 0},
      width: 2,
      height: 25,
    }
  end

  def put_velocity(paddle, {vx, vy}) do
    update_in(paddle.velocity, fn {_vx, _vy} -> {vx, vy} end)
  end

  def move(paddle, dt) do
    update_in(paddle.position, fn {x, y} ->
      {_vx, vy} = paddle.velocity
      # x2 = x + vx * dt * @movement_speed
      y2 = y + vy * dt * @movement_speed

      {x, y2}
    end)
  end
end
