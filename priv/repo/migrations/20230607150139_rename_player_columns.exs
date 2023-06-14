defmodule Tc.Repo.Migrations.RenamePlayerColumns do
  use Ecto.Migration

  def change do
    rename table("matches"), :player_left, to: :player_left_id
    rename table("matches"), :player_right, to: :player_right_id
  end
end
