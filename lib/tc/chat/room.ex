defmodule Tc.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tc.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "rooms" do
    field :description, :string
    field :name, :string
    belongs_to :owner, User, foreign_key: :user_id
    has_many :admins, User, foreign_key: :user_id
    has_many :members, User, foreign_key: :user_id
    has_many :blocked, User, foreign_key: :user_id

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
