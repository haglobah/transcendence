defmodule TcWeb.ChatLive.JoinRoomForm do
  use TcWeb, :live_component

  alias Tc.Chat
  alias Phoenix.PubSub

  def update(%{room: room} = assigns, socket) do
    changeset = Chat.change_join_room(room)

    # IO.inspect(changeset)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(room: room)
     |> assign_form(changeset)
    }
  end

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        phx-submit="try-join-room"
        phx-target={@myself}
        id={@id}>

        <.input field={@form[:id]} type="hidden"/>
        <.input label="Room password" type="text"
          field={@form[:password]}/>

        <:actions>
          <.button phx-disable-with="Joining room ...">
                  Join Room (with password)
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def handle_event("try-join-room",
    %{"try-join-room" => %{"id" => room_id, "password" => password}},
    socket
  ) do
    room = Chat.get_room!(room_id)

    socket = case Chat.join_room(room, socket.assigns.current_user.id, password) do
      {:ok, _room} ->
        PubSub.broadcast(Tc.PubSub, Chat.rooms_topic(), {:edit_room})
        socket
      {:error, %Ecto.Changeset{} = changeset} -> assign(socket, changeset: changeset) #TODO: show that password was incorrect.
    end
    {:noreply, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "try-join-room")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
