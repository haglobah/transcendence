defmodule Tc.Game.Ball do

  @movement_speed 1/300000000

  defstruct [:pos, :velocity, :width, :height]

  def new do
    %__MODULE__{
      pos: %{x: 50, y: 50},
      velocity: %{x: 2, y: 1},
      width: 2,
      height: 2,
    }
  end

  def enforce(ball, %{min: min, max: max}) do
    new_ball =
      cond do
        ball.pos.y < min -> put_in(ball.pos.y, min)
        ball.pos.y > max -> put_in(ball.pos.y, max)
        true -> ball
      end
    cond do
      ball.pos.x < min -> put_in(new_ball.pos.x, min)
      ball.pos.x > max -> put_in(new_ball.pos.x, max)
      true -> new_ball
    end
  end

  def collision(%__MODULE__{} = ball, %{min: min, max: max}) do
    cond do
      ball.pos.y == min -> update_in(ball.velocity, fn %{x: vx, y: vy} -> %{x: vx, y: -vy} end)
      ball.pos.y == max -> update_in(ball.velocity, fn %{x: vx, y: vy} -> %{x: vx, y: -vy} end)
      ball.pos.x == min -> update_in(ball.velocity, fn %{x: vx, y: vy} -> %{x: -vx, y: vy} end)
      ball.pos.x == max -> update_in(ball.velocity, fn %{x: vx, y: vy} -> %{x: -vx, y: vy} end)
      true -> ball
    end
  end

  def alter_velocity(ball, velocity) when tuple_size(velocity) == 2 do
    put_in(ball.velocity, velocity)
  end

  def move(ball, dt) do
    update_in(ball.pos, fn %{x: x, y: y} ->
      %{x: vx, y: vy} = ball.velocity
      x2 = x + vx * dt * @movement_speed
      y2 = y + vy * dt * @movement_speed

      %{x: x2, y: y2}
    end)
  end
end
