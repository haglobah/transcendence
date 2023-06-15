defmodule Tc.Repo.Migrations.AddOwner do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      add :owner_id, references(:users, type: :binary_id), null: false
    end

    create index(:rooms, [:owner_id])
  end
end
