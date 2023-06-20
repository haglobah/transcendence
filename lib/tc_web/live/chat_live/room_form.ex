defmodule TcWeb.ChatLive.RoomForm do
  use TcWeb, :live_component
  import TcWeb.CoreComponents
  alias Tc.Chat
  alias Tc.Chat.Room

  def update(%{owner_id: owner_id} = assigns, socket) do
    room = %Room{owner_id: owner_id}
    changeset = Chat.change_room(room)

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

  def add_room(
    %{assigns: %{owner_id: owner_id}} = socket,
    room_params
  ) do
    case Chat.create_room(room_params) do
      {:ok, _room} ->
        room = %Room{owner_id: owner_id, name: "", description: ""}
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
