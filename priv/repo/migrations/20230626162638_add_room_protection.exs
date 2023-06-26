defmodule Tc.Repo.Migrations.AddRoomProtection do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      add :access, :string
      add :hashed_password, :string
    end
  end
end
