defmodule Tc.Repo.Migrations.CreateRelations do
  use Ecto.Migration

  def change do
    create table(:relations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string
      add :requester_id, references(:users, type: :binary_id)
      add :receiver_id, references(:users, type: :binary_id)

      timestamps()
    end

    create index(:relations, [:requester_id])
    create index(:relations, [:receiver_id])
  end
end
