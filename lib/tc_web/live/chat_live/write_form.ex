defmodule TcWeb.ChatLive.WriteForm do
  use TcWeb, :live_component
  import TcWeb.CoreComponents
  alias Tc.Chat
  alias Tc.Chat.Message
  alias Phoenix.PubSub

  def update(%{sender_id: sender_id, room_id: room_id} = assigns, socket) do
    msg = %Message{sender_id: sender_id, room_id: room_id}
    changeset = Chat.change_message(msg)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(message: msg)
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

        <.input field={@form[:sender_id]} type="hidden"/>
        <.input field={@form[:room_id]} type="hidden"/>
        <.input
          autocomplete="off"
          phx-keydown={show_modal("edit_message")}
          phx-key="ArrowUp"
          field={@form[:content]} type="text"/>
        <:actions>
          <.button phx-disable-with="Sending...">Send</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def handle_event("save", %{"message" => message_params}, socket) do
    {:noreply, send_msg(socket, message_params)}
  end

  def send_msg(
    %{assigns: %{sender_id: sender_id, room_id: room_id}} = socket,
    message_params
    ) do
    case Chat.create_message(message_params) do
      {:ok, message} ->
        PubSub.broadcast(Tc.PubSub, Chat.msg_topic(room_id), {:chat_msg, message})

        msg = %Message{sender_id: sender_id, room_id: room_id, content: ""}
        changeset = Chat.change_message(msg)

        socket
        |> assign(message: msg)
        |> assign_form(changeset)

      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, changeset: changeset)
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "message")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
