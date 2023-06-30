defmodule Tc.Network.Relation.Query do
  import Ecto.Query

  alias Tc.Network.Relation
  alias Tc.Accounts.User

  def base do
    Relation
  end

  def get(query \\ base(), from_user_id, other_user_id) do
    from = Ecto.UUID.dump!(from_user_id)
    other = Ecto.UUID.dump!(other_user_id)

    query
    |> where([r], ^from in [r.requester_id, r.receiver_id]
              and ^other in [r.requester_id, r.receiver_id])
  end

  def list_for(query \\ base(), user_id) do
    uid = Ecto.UUID.dump!(user_id)

    query
    |> where([r], ^uid in [r.requester_id, r.receiver_id])
  end

  def list_filter_status(query \\ base(), user_id, status) do
    uid = Ecto.UUID.dump!(user_id)

    query
    |> where([r], ^uid in [r.requester_id, r.receiver_id])
    |> where([r], r.status == ^status)
    |> join(:inner, [r], u1 in User, on: r.requester_id == u1.id)
    |> join(:inner, [r], u2 in User, on: r.receiver_id == u2.id)
    |> select([r, u1, u2], {u1, u2})
  end
end
