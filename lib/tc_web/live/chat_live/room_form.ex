defmodule TcWeb.ChatLive.RoomForm do
  use TcWeb, :live_component

  alias Tc.Chat
  alias Tc.Chat.Room
  alias Phoenix.PubSub

  alias TcWeb.ChatLive

  def update(%{current_user: current_user} = assigns, socket) do
    room = %Room{owner_id: current_user.id, access: :private, password: nil}
    changeset = Chat.change_room(room)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(room: room)
     |> assign(show_password: false)
     |> assign_form(changeset)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.live_component module={ ChatLive.PrivChatSearch }
                       current_user={ @current_user }
                       id={ "new-chat-form" }/>
      <.live_component module={ ChatLive.RoomSearch }
                       current_user={ @current_user }
                       id={ "search-room-form" }/>
      <.simple_form
        for={@form}
        phx-submit="save"
        phx-change="change"
        phx-target={@myself}
        id={@id}
      >

        <.input field={@form[:owner_id]} type="hidden"/>
        <.input field={@form[:access]} type="select" options={["private", "protected", "public"]}/>
        <%= if @show_password do %>
          <.input field={@form[:password]} type="password" label="Password"/>
        <% end %>
        <.input
          autocomplete="off"
          phx-keydown={show_modal("new_room")}
          phx-key="ArrowUp"
          label="Room name"
          field={@form[:name]} type="text"/>
        <.input
          autocomplete="off"
          phx-keydown={show_modal("new_room")}
          phx-key="ArrowUp"
          label="Room description"
          field={@form[:description]} type="text"/>
        <:actions>
          <.button phx-disable-with="Creating Room...">Create Room</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def handle_event("save", %{"room" => room_params}, socket) do
    {:noreply, add_room(socket, room_params)}
  end

  def handle_event("change", %{"room" => %{"access" => access}}, socket) do
    socket = case access do
      "protected" -> assign(socket, show_password: true) #TODO: assign the room, too. That should work. Even better: Use mount, too.
      _ -> assign(socket, show_password: false)
    end

    {:noreply, socket}
  end

  def add_room(
    %{assigns: %{current_user: %{id: owner_id}}} = socket,
    room_params
  ) do
    case Chat.create_room(room_params) do
      {:ok, new_room} ->
        PubSub.broadcast(
          Tc.PubSub,
          Chat.rooms_topic(),
          {:chat_rooms, new_room}
        )

        room = %Room{owner_id: owner_id, name: "", description: "", access: :private}
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
end
