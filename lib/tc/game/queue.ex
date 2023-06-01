defmodule Tc.Game.Queue do
  alias Tc.Game
  alias Tc.Accounts

  def get() do
    player_left = Accounts.get_user_by_email("max@example.com")
    player_right = Accounts.get_user_by_email("talea@example.com")
    {player_left, player_right}
  end
end
