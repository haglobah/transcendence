defmodule Tc.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tc.Chat.Room
  alias Tc.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :content, :string
    belongs_to :sender, User
    belongs_to :room, Room

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :sender_id, :room_id])
    |> validate_required([:content, :sender_id, :room_id])
  end
end
