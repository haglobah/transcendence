defmodule Tc.Network do
  @moduledoc """
  The Network context.
  """

  import Ecto.Query, warn: false
  alias Tc.Repo

  alias Tc.Network.Relation

  @doc """
  Returns the list of relations.

  ## Examples

      iex> list_relations()
      [%Relation{}, ...]

  """
  def list_relations do
    Repo.all(Relation)
  end

  def list_relations_with_status_for(user_id, status) do
    Relation.Query.list_filter_status(user_id, status)
    |> Repo.all()
    |> Enum.map(fn {u1, u2} -> if u1.id == user_id do u2 else u1 end end)
  end

  def list_blocked_for(user_id), do: list_relations_with_status_for(user_id, :blocked)
  def list_friends_for(user_id), do: list_relations_with_status_for(user_id, :accepted)
  def list_pending_for(user_id), do: list_relations_with_status_for(user_id, :pending)
  def list_declined_for(user_id), do: list_relations_with_status_for(user_id, :declined)

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
