defmodule Tc.StatsTest do
  use Tc.DataCase

  alias Tc.Stats

  describe "matches" do
    alias Tc.Stats.Match

    import Tc.StatsFixtures

    @invalid_attrs %{score_left: nil, score_right: nil}

    test "list_matches/0 returns all matches" do
      match = match_fixture()
      assert Stats.list_matches() == [match]
    end

    test "get_match!/1 returns the match with given id" do
      match = match_fixture()
      assert Stats.get_match!(match.id) == match
    end

    test "create_match/1 with valid data creates a match" do
      valid_attrs = %{score_left: 42, score_right: 42}

      assert {:ok, %Match{} = match} = Stats.create_match(valid_attrs)
      assert match.score_left == 42
      assert match.score_right == 42
    end

    test "create_match/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stats.create_match(@invalid_attrs)
    end

    test "update_match/2 with valid data updates the match" do
      match = match_fixture()
      update_attrs = %{score_left: 43, score_right: 43}

      assert {:ok, %Match{} = match} = Stats.update_match(match, update_attrs)
      assert match.score_left == 43
      assert match.score_right == 43
    end

    test "update_match/2 with invalid data returns error changeset" do
      match = match_fixture()
      assert {:error, %Ecto.Changeset{}} = Stats.update_match(match, @invalid_attrs)
      assert match == Stats.get_match!(match.id)
    end

    test "delete_match/1 deletes the match" do
      match = match_fixture()
      assert {:ok, %Match{}} = Stats.delete_match(match)
      assert_raise Ecto.NoResultsError, fn -> Stats.get_match!(match.id) end
    end

    test "change_match/1 returns a match changeset" do
      match = match_fixture()
      assert %Ecto.Changeset{} = Stats.change_match(match)
    end
  end
end
