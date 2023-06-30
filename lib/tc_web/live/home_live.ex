defmodule TcWeb.HomeLive do
  use TcWeb, :live_view

  alias TcWeb.HomeLive
  alias Tc.Network
  alias TcWeb.Endpoint
  alias Phoenix.PubSub
  alias Tc.Activity

  import TcWeb.HomeLive.Component

  @moduledoc """
  The home page one accesses when logged in.
  """

  def render(assigns) do
    ~H"""
    <div class="flex justify-between">
      <div class="text-2xl m-10">
        <h2>This is <%= @current_user.name %>'s Home Page</h2>
      </div>
      <aside class="h-[88vh] sticky top-14 w-84 overflow-y-scroll hidden md:block">
        <.relation_list relations={@friends} socket={@socket} />
        <hr/>
        <.pending_list relations={@pending} current_user={@current_user} />
        <.link patch={~p"/friend/new"} phx-click={JS.push_focus()}>
          <.button>+</.button>
        </.link>
      </aside>
    </div>

    <.modal :if={@live_action in [:new]}
            id="add-friend"
            show
            on_cancel={JS.patch(~p"/home")}>
      <.live_component module={HomeLive.AddFriendSearch}
                       current_user={@current_user}
                       id="add-friend"/>
    </.modal>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(Network.relation_topic())
    end

    schedule_status_tick()
    socket = fetch_relations(socket)

    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("accept-friend", %{"requester-id" => req_id}, socket) do
    answer_attrs = %{requester_id: req_id, receiver_id: socket.assigns.current_user.id}

    socket = case Network.accept_friend_request(answer_attrs) do
      {:ok, _rel} ->
        PubSub.broadcast(Tc.PubSub, Network.relation_topic(), {:change_relation})
        socket
      {:error, changeset} -> assign(socket, changeset: changeset)
    end
    {:noreply, socket}
  end

  def handle_event("decline-friend", %{"requester-id" => req_id}, socket) do
    answer_attrs = %{requester_id: req_id, receiver_id: socket.assigns.current_user.id}

    socket = case Network.decline_friend_request(answer_attrs) do
      {:ok, _rel} ->
        PubSub.broadcast(Tc.PubSub, Network.relation_topic(), {:change_relation})
        socket
      {:error, changeset} -> assign(socket, changeset: changeset)
    end
    {:noreply, socket}
  end

  def handle_info({:change_relation}, socket) do
    socket = fetch_relations(socket)

    {:noreply, socket}
  end

  def handle_info(:status_tick, socket) do
    PubSub.broadcast(
      Tc.PubSub,
      Activity.status_topic(),
      {:change, socket.assigns.current_user.id, :online})
    schedule_status_tick()
    {:noreply, socket}
  end

  defp schedule_status_tick(), do: Process.send_after(self(), :status_tick, 1000)

  defp fetch_relations(socket) do
    friends = Network.list_friends_for(socket.assigns.current_user.id)
    pending = Network.list_pending_for(socket.assigns.current_user.id)

    socket
    |> assign(friends: friends)
    |> assign(pending: pending)
  end
end
