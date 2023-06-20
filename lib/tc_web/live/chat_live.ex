defmodule TcWeb.ChatLive do
  use TcWeb, :live_view
  alias Tc.Chat

  import TcWeb.ChatLive.Component
  import TcWeb.ChatLive.Messages
  alias TcWeb.ChatLive

  def render(%{live_action: action} = assigns) when action in [:show, :edit] do
    ~H"""
    <div id="mobile-sidenav" class="fixed bg-white overflow-y-scroll block md:hidden z-50 inset-0">
      <.room_list rooms={ @rooms }/>
    </div>
    <div class="flex">
      <aside class="h-[88vh] sticky top-14 w-52 overflow-y-scroll hidden md:block">
        <.room_list rooms={ @rooms }/>
      </aside>
      <div class="mx-4 w-full">
        <.link patch={~p"/chat/rooms/#{@active_room.id}/edit"}>
          <div class="text-center py-4 bg-gray-200">
            <h3 class="text-xl">
              <%= @active_room.name %>
            </h3>
            <h3 class="text-sm">
              <%= @active_room.description %>
            </h3>
          </div>
        </.link>
        <.list_messages
          messages={ @streams.messages }
          page={ @page }
          start_of_messages?={ @start_of_messages? }/>
        <.live_component module={ ChatLive.WriteForm }
          room_id={ @active_room.id }
          sender_id={ @current_user.id }
          id={ "room-#{@active_room.id}-message-form" }
          />
      </div>
    </div>

    <.modal :if={@live_action in [:new]}
            id="new-room-modal"
            show
            on_cancel={JS.patch(~p"/chat/rooms")}>
      <.live_component module={ChatLive.RoomForm}
                       owner_id={@current_user.id}
                       id={ "new-room-form" } />
    </.modal>
    <.modal :if={@live_action in [:edit]}
            id="edit-room-modal"
            show
            on_cancel={JS.patch(~p"/chat/rooms/#{@active_room.id}")}>
      <.live_component module={ChatLive.EditRoomForm}
                       room={ @active_room }
                       id={ "edit-#{@active_room.id}-form" } />
    </.modal>
    """
  end

  def render(assigns) do
    ~H"""
    <div id="mobile-sidenav" class="fixed bg-white overflow-y-scroll block md:hidden z-50 inset-0">
      <.room_list rooms={ @rooms }/>
    </div>
    <aside class="h-[88vh] sticky top-14 w-52 overflow-y-scroll hidden md:block">
      <.room_list rooms={ @rooms }/>
    </aside>

    <.modal :if={@live_action in [:new]}
            id="new-room-modal"
            show
            on_cancel={JS.patch(~p"/chat/rooms")}>
      <.live_component module={ChatLive.RoomForm}
                       owner_id={@current_user.id}
                       id={ "new-room-form" } />
    </.modal>
    """
  end

  def mount(%{"room_id" => room_id}, _session, socket) do
    active_room = Chat.get_room!(room_id)
    rooms = Chat.list_rooms_for(socket.assigns.current_user.id)
    messages = Chat.list_messages_for(room_id)

    {:ok,
    socket
    |> assign(page: 1, per_page: 20, start_of_messages?: false)
    |> assign(active_room: active_room)
    |> assign(rooms: rooms)
    |> stream(:messages, messages)
    # |> paginate_logs(1)
    }
  end

  def mount(_params, _session, socket) do
    rooms = Chat.list_rooms_for(socket.assigns.current_user.id)
    {:ok,
      socket
      |> assign(rooms: rooms)
    }
  end

  def handle_params(_params, _session, socket), do: {:noreply, socket}

  # defp paginate_msgs(socket, new_page) when new_page >= 1 do
  #   %{active_room: room, per_page: per_page, page: cur_page} = socket.assigns
  #   msgs = Chat.list_msgs(
  #     room: room,
  #     offset: (new_page - 1) * per_page,
  #     limit: per_page
  #   )

  #   {msgs, at, limit} =
  #     if new_page >= cur_page do
  #       {msgs, -1, per_page * 3 * -1}
  #     else
  #       {Enum.reverse(msgs), 0, per_page * 3}
  #     end

  #   case msgs do
  #     [] ->
  #       socket
  #       |> assign(end_of_timeline?: at == -1)
  #       |> stream(:messages, [])

  #     [_ | _] = msgs ->
  #       socket
  #       |> assign(end_of_timeline?: false)
  #       |> assign(page: new_page)
  #       |> stream(:messages, msgs, at: at, limit: limit)
  #   end
  # end
end
