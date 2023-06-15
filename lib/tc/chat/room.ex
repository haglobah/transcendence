defmodule Tc.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tc.Accounts.User

  @primary_key {:room_id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "rooms" do
    field :description, :string
    field :name, :string
    belongs_to :user, User
    has_many :admins, User, foreign_key: :id
    has_many :members, User, foreign_key: :id
    has_many :blocked, User, foreign_key: :id

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :description, :owner])
    |> validate_required([:name, :description, :owner])
  end
end
