defmodule Tc.Stats.Match.Query do
  import Ecto.Query
  alias Tc.Stats.Match

  def base do
    Match
  end

  def for_user(query \\ base(), user_id) do
    query
    |> where([m], m.player_left_id == ^user_id or m.player_right_id == ^user_id)
    |> order_by([m], {:asc, m.inserted_at})
  end
end
