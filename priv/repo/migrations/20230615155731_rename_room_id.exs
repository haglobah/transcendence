defmodule Tc.Repo.Migrations.RenameRoomId do
  use Ecto.Migration

  def change do
    rename table("rooms"), :room_id, to: :id
  end
end
