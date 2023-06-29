defmodule Tc.Network.Relation.Query do
  import Ecto.Query

  alias Tc.Network.Relation

  def base do
    Relation
  end

  def list_friends(query \\ base(), user_id) do
    uid = Ecto.UUID.dump!(user_id)

    query
    |> where([r], ^uid in [r.requester_id, r.receiver_id])
    |> where([r], r.status == :accepted)
  end
end
