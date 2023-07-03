defmodule Tc.Network do
  @moduledoc """
  The Network context.
  """

  import Ecto.Query, warn: false
  alias Tc.Repo

  alias Tc.Network.Relation

  def relation_topic() do
    "network:relation"
  end

  @doc """
  Returns the list of relations.

  ## Examples

      iex> list_relations()
      [%Relation{}, ...]

  """
  def list_relations do
    Repo.all(Relation)
  end

  def list_relations_for(user_id) do
    Relation.Query.list_for(user_id)
    |> Repo.all()
  end

  def list_users_with_status_for(user_id, status) do
    Relation.Query.list_filter_status(user_id, status)
    |> Repo.all()
    |> Enum.map(fn {u1, u2} -> if u1.id == user_id do u2 else u1 end end)
  end

  def list_relations_with_status_for(user_id, status) do
    Relation.Query.list_filter_status(user_id, status)
    |> Repo.all()
  end

  def list_pending_users(user_id), do: list_users_with_status_for(user_id, :pending)
  def list_friends_users(user_id), do: list_users_with_status_for(user_id, :accepted)
  def list_declined_users(user_id), do: list_users_with_status_for(user_id, :declined)
  def list_blocked_users(user_id), do: list_users_with_status_for(user_id, :blocked)

  def list_declined_for(user_id), do: list_relations_with_status_for(user_id, :declined)
  def list_pending_for(user_id), do: list_relations_with_status_for(user_id, :pending)
  def list_blocked_for(user_id), do: list_relations_with_status_for(user_id, :blocked)

  @doc """
  Gets a single relation.

  Raises `Ecto.NoResultsError` if the Relation does not exist.

  ## Examples

      iex> get_relation!(123)
      %Relation{}

      iex> get_relation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_relation!(id), do: Repo.get!(Relation, id)

  def get_relation(from_user_id, other_user_id) do
    Relation.Query.get(from_user_id, other_user_id)
    |> Repo.one()
  end

  def is_blocked(from_user, user) do
    user in list_blocked_users(from_user.id)
  end

  def was_blocked_by(from_user, _user) do
    case list_blocked_for(from_user.id) do
      [{_blocker, blocked} | _] -> blocked == from_user
      _ -> false
    end
  end

  def was_declined(from_user, _user) do
    case list_declined_for(from_user.id) do
      [{declined, _decliner} | _] -> declined == from_user
      _ -> false
    end
  end

  def are_friends(from_user, user) do
    user in list_friends_users(from_user.id)
  end

  def are_pending(from_user, user) do
    user in list_pending_users(from_user.id)
  end

  @doc """
  Creates a relation.

  ## Examples

      iex> create_relation(%{field: value})
      {:ok, %Relation{}}

      iex> create_relation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_relation(attrs \\ %{}) do
    %Relation{}
    |> Relation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a relation.

  ## Examples

      iex> update_relation(relation, %{field: new_value})
      {:ok, %Relation{}}

      iex> update_relation(relation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_relation(%Relation{} = relation, attrs) do
    relation
    |> Relation.changeset(attrs)
    |> Repo.update()
  end

  def send_friend_request(from_user_id, other_user_id) do
    rel = get_relation(from_user_id, other_user_id)

    case rel do
      nil -> create_relation(%{requester_id: from_user_id, receiver_id: other_user_id, status: :pending})
      %Relation{status: :pending} -> update_relation(rel, %{status: :accepted})
      %Relation{status: :declined} ->
        delete_relation(rel)
        create_relation(%{requester_id: from_user_id, receiver_id: other_user_id, status: :pending})
    end
  end

  def unfriend_user(from_user_id, other_user_id) do
    rel = get_relation(from_user_id, other_user_id)

    case rel do
      nil -> {:error, %Ecto.Changeset{}}
      _ -> delete_relation(rel)
    end
  end

  def accept_friend_request(%{requester_id: req_id, receiver_id: rec_id}) do
    rel = get_relation(req_id, rec_id)
    update_relation(rel, %{status: :accepted})
  end

  def decline_friend_request(%{requester_id: req_id, receiver_id: rec_id}) do
    rel = get_relation(req_id, rec_id)
    update_relation(rel, %{status: :declined})
  end

  def block_user(from_user_id, other_user_id) do
    case get_relation(from_user_id, other_user_id) do
      nil -> create_relation(%{requester_id: from_user_id, receiver_id: other_user_id, status: :blocked})
      rel -> update_relation(rel, %{status: :blocked})
    end
  end

  def unblock_user(from_user_id, other_user_id) do
    rel = get_relation(from_user_id, other_user_id)

    case rel do
      nil -> {:error, %Ecto.Changeset{}}
      _ -> delete_relation(rel)
    end
  end

  @doc """
  Deletes a relation.

  ## Examples

      iex> delete_relation(relation)
      {:ok, %Relation{}}

      iex> delete_relation(relation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_relation(%Relation{} = relation) do
    Repo.delete(relation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking relation changes.

  ## Examples

      iex> change_relation(relation)
      %Ecto.Changeset{data: %Relation{}}

  """
  def change_relation(%Relation{} = relation, attrs \\ %{}) do
    Relation.changeset(relation, attrs)
  end
end
