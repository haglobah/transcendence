defmodule Tc.Repo.Migrations.ChangeSecretToBinary do
  use Ecto.Migration

  def change do
      execute "ALTER TABLE users ALTER COLUMN otp_secret TYPE bytea USING otp_secret::bytea"
  end
end
