defmodule TcWeb.ChatLive.EditRoomForm do
  use TcWeb, :live_component
  import TcWeb.CoreComponents

  alias Tc.Chat
  alias Tc.Chat.Room
  alias Phoenix.PubSub

  alias TcWeb.ChatLive

  def update(
    %{room:
      %{owner_id: owner_id, name: name, description: description, access: access} = room,
      user: user} = assigns,
    socket
  ) do
    for_room_form = %Room{owner_id: owner_id, name: name, description: description, access: access}
    changeset = Chat.change_room(for_room_form)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(room: room)
     |> assign(user: user)
     |> assign(show_password: access == :protected)
     |> assign_form(changeset)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= if is_admin(@room, @user) do %>
        <.live_component  module={ChatLive.UserSearch}
                          room={@room}
                          id={"room-#{@room.id}-user-search"} />
      <% end %>
      <.simple_form
        for={@form}
        phx-submit="save"
        phx-change="change"
        phx-target={@myself}
        id={@id}
      >

        <.input field={@form[:owner_id]} type="hidden"/>
        <.input
          autocomplete="off"
          phx-keydown={show_modal("edit_room")}
          phx-key="ArrowUp"
          label="Room name"
          field={@form[:name]} type="text"/>
        <.input
          autocomplete="off"
          phx-keydown={show_modal("edit_room")}
          phx-key="ArrowUp"
          label="Room description"
          field={@form[:description]} type="text"/>
        <.input :if={@user.id == @room.owner_id} field={@form[:access]} type="select" options={["private", "protected", "public"]}/>
        <%= if @show_password && @user.id == @room.owner_id do %>
          <.input field={@form[:password]} type="password" label="Password"/>
        <% end %>
        <:actions>
          <.button phx-disable-with="Changing Room...">Change Room</.button>
        </:actions>
      </.simple_form>
      <.live_component module={ChatLive.MemberList}
                       room={@room}
                       user={@user}
                       id={"room-#{@room.id}-member-list"} />
    </div>
    """
  end

  def handle_event("change", %{"room" => %{"access" => access}}, socket) do
    socket = case access do
      "protected" -> assign(socket, show_password: true)
      _ -> assign(socket, show_password: false)
    end

    {:noreply, socket}
  end

  def handle_event("save", %{"room" => room_params}, socket) do
    {:noreply, edit_room(socket, room_params)}
  end

  def edit_room(
    %{assigns: %{room: orig_room}} = socket,
    room_params
  ) do
    case Chat.update_room(orig_room, room_params) do
      {:ok, new_room} ->
        PubSub.broadcast(Tc.PubSub, Chat.rooms_topic(), {:edit_room})
        room = %Room{name: new_room.name, description: new_room.description, access: new_room.access}
        changeset = Chat.change_room(room)

        socket
        |> assign(room: room)
        |> assign_form(changeset)

      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, changeset: changeset)
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "room")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  defp is_admin(room, user) do
    case room.admins do
      nil -> false
      _ -> user.id in room.admins
    end
  end
end
