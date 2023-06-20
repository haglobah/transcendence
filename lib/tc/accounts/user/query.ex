defmodule Tc.Accounts.User.Query do
  import Ecto.Query
  alias Tc.Accounts.User

  def base do
    User
  end

  def search(query \\ base(), search_query, exceptions) do
    search_query = "%#{search_query}%"
    exceptions = Enum.map(exceptions, fn str -> Ecto.UUID.dump!(str) end)

    query
    |> order_by(asc: :name)
    |> where([u], ilike(u.name, ^search_query))
    |> where([u], fragment("(?) <> all(?)", u.id, ^exceptions))
    |> limit(5)
  end
end
