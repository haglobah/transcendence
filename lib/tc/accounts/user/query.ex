defmodule Tc.Accounts.User.Query do
  import Ecto.Query
  alias Tc.Accounts.User

  def base do
    User
  end

  def search(query \\ base(), search_query) do
    search_query = "%#{search_query}%"

    query
    |> order_by(asc: :name)
    |> where([u], ilike(u.name, ^search_query))
    |> limit(5)
  end
end
