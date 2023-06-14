defmodule Tc.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :score_left, :integer
      add :score_right, :integer
      add :player_left, references(:users, on_delete: :nothing, type: :binary_id), null: false
      add :player_right, references(:users, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:matches, [:player_left])
    create index(:matches, [:player_right])
  end
end
