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
    field :access, Ecto.Enum, values: [:public, :protected, :private]
    field :password, :string, virtual: true, redact: :true
    field :hashed_password, :string, redact: :true
    field :admins, {:array, :binary_id}
    field :members, {:array, :binary_id}
    field :blocked, {:array, :binary_id}
    has_many :messages, Message

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :description, :owner_id, :admins, :members, :access, :password])
    |> validate_required([:name, :description, :owner_id, :access])
    |> maybe_validate_password()
  end

  defp maybe_validate_password(changeset) do
    case get_change(changeset, :access) do
      :protected ->
        changeset
        |> validate_required([:password])
        |> hash_password()

      _ -> changeset
    end
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)

    if password && changeset.valid? do
      changeset
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
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

  def change_join(room, attrs) do
    room
    |> cast(attrs, [:members, :password])
    |> validate_required([:members, :password])
  end
end
