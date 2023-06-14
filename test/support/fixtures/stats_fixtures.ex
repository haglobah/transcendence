defmodule Tc.StatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tc.Stats` context.
  """

  @doc """
  Generate a match.
  """
  def match_fixture(attrs \\ %{}) do
    {:ok, match} =
      attrs
      |> Enum.into(%{
        score_left: 42,
        score_right: 42
      })
      |> Tc.Stats.create_match()

    match
  end
end
