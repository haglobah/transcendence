defmodule Tc.Stats do
  @moduledoc """
  The Stats context.
  """

  import Ecto.Query, warn: false
  alias Tc.Repo

  alias Tc.Stats.Match
  alias Tc.Accounts

  @doc """
  Returns the list of matches.

  ## Examples

      iex> list_matches()
      [%Match{}, ...]

  """
  def list_matches do
    Repo.all(Match)
  end

  @doc """
  Gets a single match.

  Raises `Ecto.NoResultsError` if the Match does not exist.

  ## Examples

      iex> get_match!(123)
      %Match{}

      iex> get_match!(456)
      ** (Ecto.NoResultsError)

  """
  def get_match!(id), do: Repo.get!(Match, id)

  @doc """
  Gets all matches in which a user participated.

  Raises `Ecto.NoResultsError` if the Match does not exist.

  ## Examples

      iex> list_matches_for_user(user.id)
      [%Match{}, ...]

      iex> list_matches_for_user(nobody.id)
      ** (Ecto.NoResultsError)

  """

  def list_matches_for_user(user_id) do

    Match.Query.for_user(user_id)
    |> Repo.all()
    |> Enum.map(&insert_players/1)
  end

  def insert_players(match) do
    player_left = Accounts.get_user!(match.player_left_id)
    player_right = Accounts.get_user!(match.player_right_id)

    %{match |
      player_left: player_left,
      player_right: player_right
    }
  end

  def calculate_stats_for(user, matches) do
    wins = Enum.count(matches, &is_win(user, &1))
    draws = Enum.count(matches, &is_draw(user, &1))
    losses = Enum.count(matches) - wins - draws
    ladder = calculate_ladder(wins, losses, draws)

    %{wins: wins, losses: losses, draws: draws, ladder: ladder}
  end

  def calculate_ladder(wins, _losses, _draws) do
    cond do
      wins > 20 -> :gold
      wins > 7 -> :silver
      true -> :bronze
    end
  end

  defp is_win(user,
    %{player_left: %{id: left_id}, player_right: %{id: right_id}, score_left: left, score_right: right}
  ) do
    case user.id do
      ^left_id -> left > right
      ^right_id -> left < right
    end
  end

  defp is_draw(_user,
    %{score_left: left, score_right: right}
  ) do
      left == right
  end
  @doc """
  Creates a match.

  ## Examples

      iex> create_match(%{field: value})
      {:ok, %Match{}}

      iex> create_match(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_match(attrs \\ %{}) do
    %Match{}
    |> Match.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match.

  ## Examples

      iex> update_match(match, %{field: new_value})
      {:ok, %Match{}}

      iex> update_match(match, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_match(%Match{} = match, attrs) do
    match
    |> Match.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match.

  ## Examples

      iex> delete_match(match)
      {:ok, %Match{}}

      iex> delete_match(match)
      {:error, %Ecto.Changeset{}}

  """
  def delete_match(%Match{} = match) do
    Repo.delete(match)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match changes.

  ## Examples

      iex> change_match(match)
      %Ecto.Changeset{data: %Match{}}

  """
  def change_match(%Match{} = match, attrs \\ %{}) do
    Match.changeset(match, attrs)
  end
end
