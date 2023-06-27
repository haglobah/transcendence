defmodule Tc.Chat do
  @moduledoc """
  The Chat context.
  """

  alias Ecto.Changeset
  alias Tc.Repo

  alias Tc.Chat.Room
  alias Tc.Chat.Message


  def rooms_topic() do
    "chat:rooms"
  end
  def msg_topic(room_id) do
    "chat:#{room_id}:msg"
  end

  @doc """
  Returns the list of rooms.

  ## Examples

      iex> list_rooms()
      [%Room{}, ...]

  """
  def list_rooms do
    Repo.all(Room)
  end

  def list_rooms_for(user_id) do
    # Room.Query.for_user(user_id)
    Room.Query.for_user(user_id)
    |> Repo.all()
  end

  def search_rooms(%{query: search_query, except: except}) do
    Room.Query.room_search(search_query, except)
    |> Repo.all()
  end
  @doc """
  Gets a single room.

  Raises `Ecto.NoResultsError` if the Room does not exist.

  ## Examples

      iex> get_room!(123)
      %Room{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room!(id), do: Repo.get!(Room, id)

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{name: "The room", description: "This particular room", owner_id: user.id})
      {:ok, %Room{}}

      iex> create_room(%{name: 2, description: "No particular room", owner_id: nobody.id})
      {:error, %Ecto.Changeset{}}

  """
  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(insert_owner(attrs))
    |> Repo.insert()
  end

  def insert_owner(%{"owner_id" => owner_id} = attrs) do
    attrs
    |> Map.put("admins", [owner_id])
    |> Map.put("members", [owner_id])
  end

  def create_privchat(%{"members" => members} = attrs) do
    %Room{}
    |> Room.change_chat(attrs |> Map.put("owner_id", hd(members)))
    |> Repo.insert()
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  def join_room(%Room{} = room, user_id) do
    add_member(room, user_id)
  end

  def join_room(%Room{} = room, user_id, password) do
    case valid_password?(room, password) do
      true -> add_member(room, user_id)
      false -> %Ecto.Changeset{} |> Changeset.add_error(:password, "is not valid")
    end
  end

  def valid_password?(%Room{hashed_password: hashed_password}, password)
    when is_binary(hashed_password) and byte_size(password) > 0 do
      Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end


  def add_member(%Room{members: members} = room, user_id) do
    attrs = %{members: [user_id | members]}

    room
    |> Room.change_members(attrs)
    |> Repo.update()
  end

  def rm_member(%Room{members: members} = room, user_id) do
    attrs = %{members: members -- [user_id]}

    room
    |> Room.change_members(attrs)
    |> Repo.update()
  end

  def add_admin(%Room{admins: admins} = room, user_id) do
    attrs = %{admins: [user_id | admins]}

    room
    |> Room.change_admins(attrs)
    |> Repo.update()
  end

  def rm_admin(%Room{admins: admins} = room, user_id) do
    attrs = %{admins: admins -- [user_id]}

    room
    |> Room.change_admins(attrs)
    |> Repo.update()
  end

  def add_blocked(%Room{blocked: blocked} = room, user_id) do
    attrs = case blocked do
      nil -> %{blocked: [user_id]}
      _ -> %{blocked: [user_id | blocked]}
    end

    room
    |> Room.change_blocked(attrs)
    |> Repo.update()
  end

  def rm_blocked(%Room{blocked: blocked} = room, user_id) do
    attrs = %{blocked: blocked -- [user_id]}

    room
    |> Room.change_blocked(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a room.

  ## Examples

      iex> delete_room(room)
      {:ok, %Room{}}

      iex> delete_room(room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{data: %Room{}}

  """
  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  def list_messages_for(room_id) do
    Message.Query.for_room(room_id)
    |> Repo.all()
    |> Repo.preload(:sender)
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{content: "Hi from iex", sender_id: user.id, room_id: a_room.id})
      {:ok, %Message{}}

      iex> create_message(%{})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  def preload(msg, :sender) do
    Repo.preload(msg, :sender)
  end
  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
