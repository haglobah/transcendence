defmodule TcWeb.ChatLive do
  use TcWeb, :live_view
  alias Tc.Chat

  import TcWeb.ChatLive.Component
  import TcWeb.ChatLive.Messages
  alias TcWeb.ChatLive

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <div id="mobile-sidenav" class="fixed bg-white overflow-y-scroll block md:hidden z-50 inset-0">
      <.room_list rooms={ @rooms }/>
    </div>
    <div class="flex">
      <aside class="h-[88vh] sticky top-14 w-52 overflow-y-scroll hidden md:block">
        <.room_list rooms={ @rooms }/>
      </aside>
      <div>
        <.list_messages
          messages={ @streams.messages }
          page={ @page }
          start_of_messages?={ @start_of_messages? }/>
        <.live_component module={ ChatLive.WriteForm }
          room_id={ @active_room }
          sender_id={ @current_user.id }
          id={ "room-#{@active_room}-message-form" }
          />
      </div>
    </div>

    <.modal :if={@live_action in [:new]}
            id="room-modal"
            show
            on_cancel={JS.patch(~p"/chat/rooms")}>
      <.live_component module={ChatLive.RoomForm}
                       owner_id={@current_user.id}
                       id={ "new-room-form" } />
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
            id="room-modal"
            show
            on_cancel={JS.patch(~p"/chat/rooms")}>
      <.live_component module={ChatLive.RoomForm}
                       owner_id={@current_user.id}
                       id={ "new-room-form" } />
    </.modal>
    """
  end

  def mount(%{"room_id" => room_id}, _session, socket) do
    messages = Chat.list_messages_for(room_id)

    {:ok,
    socket
    |> assign(page: 1, per_page: 20, start_of_messages?: false)
    |> assign(active_room: room_id)
    |> assign(rooms: Chat.list_rooms())
    |> stream(:messages, messages)
    # |> paginate_logs(1)
    }
  end

  def mount(_params, _session, socket) do
    # IO.inspect(socket.assigns)
    {:ok,
      socket
      |> assign(rooms: Chat.list_rooms())
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
