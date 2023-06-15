defmodule Tc.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms, primary_key: false) do
      add :room_id, :binary_id, primary_key: true
      add :name, :string
      add :description, :string
      add :owner_id, references(:users, type: :binary_id), null: false
      add :admins, {:array, :binary_id}
      add :members, {:array, :binary_id}
      add :blocked, {:array, :binary_id}

      timestamps()
    end
  end
end
