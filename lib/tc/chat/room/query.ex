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

  def room_search(query \\ base(), search_query, except) do
    search_query = "%#{search_query}"
    exceptions = to_binary(except)
    IO.inspect(except)

    query
    |> where([r], r.access in [:public, :protected])
    |> where([r], ilike(r.name, ^search_query))
    |> where([r], fragment("(?) <> all(?)", r.id, ^exceptions))
    |> order_by(asc: :name)
    |> limit(5)
  end

  def to_binary(id_list) do
    Enum.map(id_list, fn str -> Ecto.UUID.dump!(str) end)
  end
end
