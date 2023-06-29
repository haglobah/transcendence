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

  def list_relations_with_status_for(user_id, status) do
    Relation.Query.list_filter_status(user_id, status)
    |> Repo.all()
    |> Enum.map(fn {u1, u2} -> if u1.id == user_id do u2 else u1 end end)
  end

  def list_friends_for(user_id), do: list_relations_with_status_for(user_id, :accepted)
  def list_pending_for(user_id), do: list_relations_with_status_for(user_id, :pending)
  def list_declined_for(user_id), do: list_relations_with_status_for(user_id, :declined)
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
    user.id in list_blocked_for(from_user.id)
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
      _ -> update_relation(rel, %{status: :accepted})
    end
  end

  def block_user(from_user_id, other_user_id) do
    %Relation{}
  end

  def unblock_user(from_user_id, other_user_id) do
    %Relation{}
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
