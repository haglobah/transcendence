defmodule Tc.Game.Paddle do

  @movement_speed 1/30000000

  defstruct [:position, :velocity, :width, :height]

  def new do
    %__MODULE__{
      position: {0, 0},
      velocity: {0, 0},
      width: 10,
      height: 10,
    }
  end

  def begin(paddle) do
    alter_velocity(paddle, {Enum.random(50..100), Enum.random(50..100)})
  end

  def alter_velocity(paddle, velocity) when tuple_size(velocity) == 2 do
    put_in(paddle.velocity, velocity)
  end

  def move(_state, paddle, dt) do
    update_in(paddle.position, fn {x, y} ->
      {_vx, vy} = paddle.velocity
      # x2 = x + vx * dt * @movement_speed
      y2 = y + vy * dt * @movement_speed

      {x, y2}
    end)
  end
end
