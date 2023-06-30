defmodule Tc.NetworkTest do
  use Tc.DataCase

  alias Tc.Network

  describe "relations" do
    alias Tc.Network.Relation

    import Tc.NetworkFixtures

    @invalid_attrs %{status: nil}

    test "list_relations/0 returns all relations" do
      relation = relation_fixture()
      assert Network.list_relations() == [relation]
    end

    test "get_relation!/1 returns the relation with given id" do
      relation = relation_fixture()
      assert Network.get_relation!(relation.id) == relation
    end

    test "create_relation/1 with valid data creates a relation" do
      valid_attrs = %{status: "some status"}

      assert {:ok, %Relation{} = relation} = Network.create_relation(valid_attrs)
      assert relation.status == "some status"
    end

    test "create_relation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Network.create_relation(@invalid_attrs)
    end

    test "update_relation/2 with valid data updates the relation" do
      relation = relation_fixture()
      update_attrs = %{status: "some updated status"}

      assert {:ok, %Relation{} = relation} = Network.update_relation(relation, update_attrs)
      assert relation.status == "some updated status"
    end

    test "update_relation/2 with invalid data returns error changeset" do
      relation = relation_fixture()
      assert {:error, %Ecto.Changeset{}} = Network.update_relation(relation, @invalid_attrs)
      assert relation == Network.get_relation!(relation.id)
    end

    test "delete_relation/1 deletes the relation" do
      relation = relation_fixture()
      assert {:ok, %Relation{}} = Network.delete_relation(relation)
      assert_raise Ecto.NoResultsError, fn -> Network.get_relation!(relation.id) end
    end

    test "change_relation/1 returns a relation changeset" do
      relation = relation_fixture()
      assert %Ecto.Changeset{} = Network.change_relation(relation)
    end
  end
end
