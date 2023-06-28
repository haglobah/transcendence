defmodule Tc.NetworkFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tc.Network` context.
  """

  @doc """
  Generate a relation.
  """
  def relation_fixture(attrs \\ %{}) do
    {:ok, relation} =
      attrs
      |> Enum.into(%{
        status: "some status"
      })
      |> Tc.Network.create_relation()

    relation
  end
end
