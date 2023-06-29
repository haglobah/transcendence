defmodule TcWeb.HomeLive do
  use TcWeb, :live_view

  alias TcWeb.HomeLive
  alias Tc.Network
  alias TcWeb.Endpoint

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
        <.relation_list relations={@friends}/>
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

    socket = fetch_friends(socket)

    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_info({:change_relation}, socket) do
    socket = fetch_friends(socket)

    {:noreply, socket}
  end

  defp fetch_friends(socket) do
    friends = Network.list_friends_for(socket.assigns.current_user.id)
    pending = Network.list_pending_for(socket.assigns.current_user.id)

    socket
    |> assign(friends: friends)
    |> assign(pending: pending)
  end
end
