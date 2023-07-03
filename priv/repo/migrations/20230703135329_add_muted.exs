defmodule Tc.Repo.Migrations.AddMuted do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      add :muted, {:array, :binary_id}
    end
  end
end
