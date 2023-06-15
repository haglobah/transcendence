defmodule Tc.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :string
      add :sender_id, references(:users, on_delete: :nothing, type: :binary_id), null: false
      add :room_id, references(:rooms, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:messages, [:sender_id])
    create index(:messages, [:room_id])
  end
end
