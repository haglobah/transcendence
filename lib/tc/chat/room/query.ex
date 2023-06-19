defmodule Tc.Chat.Room.Query do
  import Ecto.Query
  alias Tc.Chat.Room

  def base do
    Room
  end

  def for_user(query \\ base(), user_id) do
    user_id = Ecto.UUID.dump!(user_id)
    query
    |> where([r], ^user_id == fragment("any(?)", r.members))
  end
end
