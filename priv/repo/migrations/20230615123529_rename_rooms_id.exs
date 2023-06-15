defmodule Tc.Repo.Migrations.RenameRoomsId do
  use Ecto.Migration

  def change do
    rename table("rooms"), :id, to: :room_id
  end
end
