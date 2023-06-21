defmodule TcWeb.ChatLive.MemberList do
  use TcWeb, :live_component

  import TcWeb.ChatLive.Component
  alias Tc.Accounts

  def update(%{room: _room, user: _user} = assigns, socket) do

    {:ok,
      socket
      |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
      <div class="bg-gray-100 my-2 rounded w-120">
        <%= for user <- Accounts.get_users(@room.members) do %>
          <.display_user user={user}>
            <%= if is_admin(@room, @user) do %>
              <.button :if={!is_admin(@room, user) && @user.id == user.id}
                phx-target={@myself}
                phx-click="rm-admin" phx-value-user-id={user.id}>
                Remove Admin rights
              </.button>
              <.button :if={is_admin(@room, user)}
                phx-target={@myself}
                phx-click="to-admin" phx-value-user-id={user.id}>
                Make an admin
              </.button>
              <.button :if={true}
                phx-target={@myself}
                phx-click="kick" phx-value-user-id={user.id}>
                Kick from room
              </.button>
            <% end %>
          </.display_user>
        <% end %>
      </div>
    """
  end

  def handle_event("to-admin", %{"user-id" => _user_id}, socket) do
    new_room = socket.assigns.room

    {:noreply, assign(socket, room: new_room)}
  end

  def handle_event("kick", %{"user-id" => _user_id}, socket) do
    new_room = socket.assigns.room

    {:noreply, assign(socket, room: new_room)}
  end

  defp is_admin(room, user) do
    user.id in room.admins
  end
end
