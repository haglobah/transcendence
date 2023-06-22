defmodule Tc.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tc.Accounts.User
  alias Tc.Chat.Message

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "rooms" do
    field :description, :string
    field :name, :string
    belongs_to :owner, User
    field :admins, {:array, :binary_id}
    field :members, {:array, :binary_id}
    field :blocked, {:array, :binary_id}
    has_many :messages, Message

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :description, :owner_id, :admins, :members])
    |> validate_required([:name, :description, :owner_id])
  end

  def change_members(room, attrs) do
    room
    |> cast(attrs, [:members])
    |> validate_required([:members])
  end

  def change_admins(room, attrs) do
    room
    |> cast(attrs, [:admins])
    |> validate_required([:admins])
  end

  def change_blocked(room, attrs) do
    room
    |> cast(attrs, [:blocked])
    |> validate_required([:blocked])
  end

  def change_chat(room, attrs) do
    room
    |> cast(attrs, [:owner_id, :members])
    |> validate_required([:owner_id, :members])
  end
end
