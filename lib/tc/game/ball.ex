defmodule Tc.Game.Ball do

  @movement_speed 1/30000000

  defstruct [:position, :velocity, :width, :height]

  def new do
    %__MODULE__{
      position: {0, 0},
      velocity: {0, 0},
      width: 2,
      height: 2,
    }
  end

  def begin(ball) do
    alter_velocity(ball, {Enum.random(50..100), Enum.random(50..100)})
  end

  def alter_velocity(ball, velocity) when tuple_size(velocity) == 2 do
    put_in(ball.velocity, velocity)
  end

  def move(_state, ball, dt) do
    update_in(ball.position, fn {x, y} ->
      {vx, vy} = ball.velocity
      x2 = x + vx * dt * @movement_speed
      y2 = y + vy * dt * @movement_speed

      {x2, y2}
    end)
  end
end
