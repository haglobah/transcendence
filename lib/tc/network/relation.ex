defmodule Tc.Network.Relation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "relations" do
    field :status, Ecto.Enum, values: [:pending, :accepted, :denied, :blocked]
    field :requester_id, :binary_id
    field :receiver_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(relation, attrs) do
    relation
    |> cast(attrs, [:status, :requester_id, :receiver_id])
    |> validate_required([:status, :requester_id, :receiver_id])
  end

  def change_staus(relation, attrs) do
    relation
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end
