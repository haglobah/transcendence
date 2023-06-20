defmodule Tc.Accounts.User.Query do
  import Ecto.Query
  alias Tc.Accounts.User

  def base do
    User
  end

  def search_addable_users(query \\ base(), search_query, exceptions) do
    search_query = "%#{search_query}%"
    exceptions = to_binary(exceptions)

    query
    |> order_by(asc: :name)
    |> where([u], ilike(u.name, ^search_query))
    |> where([u], fragment("(?) <> all(?)", u.id, ^exceptions))
    |> limit(5)
  end

  def get_users(query \\ base(), user_id_list) do
    query
    |> where([u], u.id in ^user_id_list)
  end

  def to_binary(id_list) do
    Enum.map(id_list, fn str -> Ecto.UUID.dump!(str) end)
  end
end
