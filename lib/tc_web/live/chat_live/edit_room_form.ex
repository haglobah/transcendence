defmodule TcWeb.ChatLive.EditRoomForm do
  use TcWeb, :live_component
  import TcWeb.CoreComponents
  alias Tc.Chat
  alias Tc.Chat.Room

  def update(
    %{room: %{owner_id: owner_id, name: name, description: description} = room} = assigns,
    socket
  ) do
    for_room_form = %Room{owner_id: owner_id, name: name, description: description}
    changeset = Chat.change_room(for_room_form)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(room: room)
     |> assign_form(changeset)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        phx-submit="save"
        phx-target={@myself}
        id={@id}
      >

        <.input field={@form[:owner_id]} type="hidden"/>
        <.input
          autocomplete="off"
          phx-keydown={show_modal("edit_room")}
          phx-key="ArrowUp"
          field={@form[:name]} type="text"/>
        <.input
          autocomplete="off"
          phx-keydown={show_modal("edit_room")}
          phx-key="ArrowUp"
          field={@form[:description]} type="text"/>
        <:actions>
          <.button phx-disable-with="Changing Room...">Change Room</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def handle_event("save", %{"room" => room_params}, socket) do
    {:noreply, add_room(socket, room_params)}
  end

  def add_room(
    %{assigns: %{room: room}} = socket,
    room_params
  ) do
    case Chat.update_room(%Room{id: room.id}, room_params) do
      {:ok, _room} ->
        room = %Room{name: room.name, description: room.description}
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
