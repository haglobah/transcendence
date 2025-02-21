defmodule TcWeb.ChatLive.MemberList do
  use TcWeb, :live_component

  alias Tc.Accounts
  alias Tc.Chat
  alias Phoenix.PubSub

  import TcWeb.Component

  def update(%{room: room, user: user} = assigns, socket) do

    {:ok,
      socket
      |> assign(assigns)
      |> assign(room: room)
      |> assign(user: user)
    }
  end

  def render(assigns) do
    ~H"""
      <div class="bg-gray-100 my-2 rounded w-120">
        <%= for member <- Accounts.get_users(@room.members) do %>
          <.display_user user={member}>
            <%= if is_admin(@room, @user) do %>
              <.button :if={is_admin(@room, member) && isnt_me(@user, member) && !is_owner(@room, member)}
                phx-target={@myself}
                phx-click="rm-admin" phx-value-member-id={member.id}>
                Remove Admin rights
              </.button>
              <.button :if={!is_admin(@room, member)}
                phx-target={@myself}
                phx-click="make-admin" phx-value-member-id={member.id}>
                Make an admin
              </.button>
              <.button :if={isnt_me(@user, member) && !is_owner(@room, member)}
                phx-target={@myself}
                phx-click="kick" phx-value-member-id={member.id}>
                Kick from room
              </.button>
              <.button :if={is_me(@user, member)}
                phx-target={@myself}
                phx-click="kick" phx-value-member-id={member.id}>
                Leave room
              </.button>
              <.button :if={!Chat.is_muted(member, @room) && isnt_me(@user, member)}
                phx-target={@myself}
                phx-click="mute" phx-value-member-id={member.id}>
                Mute
              </.button>
              <.button :if={Chat.is_muted(member, @room) && isnt_me(@user, member)}
                phx-target={@myself}
                phx-click="unmute" phx-value-member-id={member.id}>
                Unmute
              </.button>
            <% end %>
          </.display_user>
        <% end %>
      </div>
    """
  end

  def handle_event("make-admin", %{"member-id" => member_id}, socket) do
    socket = change_room(&Chat.add_admin/2, member_id, socket)

    {:noreply, socket}
  end

  def handle_event("rm-admin", %{"member-id" => member_id}, socket) do
    socket = change_room(&Chat.rm_admin/2, member_id, socket)

    {:noreply, socket}
  end

  def handle_event("kick", %{"member-id" => member_id}, socket) do
    socket = change_room(&Chat.rm_member/2, member_id, socket)

    {:noreply, socket}
  end

  def handle_event("mute", %{"member-id" => member_id}, socket) do
    socket = change_room(&Chat.mute_member/2, member_id, socket)

    {:noreply, socket}
  end

  def handle_event("unmute", %{"member-id" => member_id}, socket) do
    socket = change_room(&Chat.unmute_member/2, member_id, socket)

    {:noreply, socket}
  end

  defp change_room(change_fun, member_id, socket) do
    case change_fun.(socket.assigns.room, member_id) do
      {:ok, room} ->
        PubSub.broadcast(Tc.PubSub, Chat.rooms_topic(), {:edit_room})
        assign(socket, room: room)
      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, changeset: changeset)
    end
  end

  defp is_admin(room, user), do: user.id in room.admins
  defp is_owner(room, user), do: user.id == room.owner_id
  defp isnt_me(user, other), do: user.id != other.id
  defp is_me(user, other), do: user.id == other.id
end
