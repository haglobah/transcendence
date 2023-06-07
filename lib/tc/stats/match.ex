defmodule Tc.Stats.Match do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tc.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "matches" do
    field :score_left, :integer
    field :score_right, :integer
    belongs_to :player_left, User
    belongs_to :player_right, User

    timestamps()
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:score_left, :score_right, :player_left_id, :player_right_id])
    |> validate_required([:score_left, :score_right, :player_left_id, :player_right_id])
  end
end
