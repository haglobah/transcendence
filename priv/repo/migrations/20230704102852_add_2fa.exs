defmodule Tc.Repo.Migrations.Add2fa do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_2fa, :boolean
      add :otp_secret, :binary
    end
  end
end
