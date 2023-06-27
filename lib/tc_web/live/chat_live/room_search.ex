defmodule TcWeb.ChatLive.RoomSearch do
  use TcWeb, :live_component

  import TcWeb.ChatLive.Component
  alias Tc.Chat
  alias Phoenix.PubSub

  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(assigns)
      |> assign(joinable_rooms: [])
    }
  end

  def render(assigns) do
    ~H"""
    <form action="" novalidate="" role="search" phx-change="change" phx-target={@myself}>
      <div class="group relative flex h-12">
        <svg
          viewBox="0 0 20 20"
          fill="none"
          aria-hidden="true"
          class="pointer-events-none absolute left-3 top-0 h-full w-5 stroke-zinc-500"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M12.01 12a4.25 4.25 0 1 0-6.02-6 4.25 4.25 0 0 0 6.02 6Zm0 0 3.24 3.25"
          >
          </path>
        </svg>

        <input
          id="search-input"
          name="search[query]"
          class="flex-auto rounded-lg appearance-none bg-transparent pl-10 text-zinc-900 outline-none focus:outline-none border-slate-200 focus:border-slate-200 focus:ring-0 focus:shadow-none placeholder:text-zinc-500 focus:w-full focus:flex-none sm:text-sm [&::-webkit-search-cancel-button]:hidden [&::-webkit-search-decoration]:hidden [&::-webkit-search-results-button]:hidden [&::-webkit-search-results-decoration]:hidden pr-4"
          style={
            @joinable_rooms != [] &&
              "border-bottom-left-radius: 0; border-bottom-right-radius: 0; border-bottom: none"
          }
          aria-autocomplete="both"
          aria-controls="searchbox__results_list"
          autocomplete="off"
          autocorrect="off"
          autocapitalize="off"
          enterkeyhint="search"
          spellcheck="false"
          placeholder="Search for a room to join..."
          type="search"
          value=""
          tabindex="0"
        />
      </div>

      <div
        :if={@joinable_rooms != []}
        class="divide-y divide-slate-200 overflow-y-auto rounded-b-lg border-t border-slate-200 text-sm leading-6"
        id="searchbox__results_list"
        role="listbox"
      >
        <%= for room <- @joinable_rooms do %>
          <.display_room room={room}>
            <%= if room.access == :public do %>
              <.button phx-click="join-room"
                      phx-value-room={room.id}
                      phx-target={@myself}>
                      Join Room
              </.button>
            <% else %>
              <.button phx-click="try-join-room"
                      phx-value-room={room.id}
                      phx-target={@myself}>
                      Join Room (with password)
              </.button>
            <% end %>
          </.display_room>
        <% end %>
      </div>
    </form>
    """
  end

  def handle_event("change", %{"search" => %{"query" => ""}}, socket) do
    {:noreply, assign(socket, joinable_rooms: [])}
  end
  def handle_event("change",
    %{"search" => %{"query" => search_query}},
    %{assigns: %{current_user: current_user}} = socket) do

    member_room_ids = Enum.map(Chat.list_rooms_for(current_user.id), &(&1.id))

    except = member_room_ids # ++ ids of the rooms the user is blocked from
    joinable_rooms = Chat.search_rooms(%{query: search_query, except: except})
    {:noreply, assign(socket, joinable_rooms: joinable_rooms)}
  end

  def handle_event("join-room", %{"room" => room_id}, socket) do
    room = Chat.get_room!(room_id)
    socket = case Chat.join_room(room, socket.assigns.current_user.id) do
      {:ok, room} ->
        PubSub.broadcast(Tc.PubSub, Chat.rooms_topic(), {:chat_rooms, room})
        socket
      {:error, %Ecto.Changeset{} = changeset} -> assign(socket, changeset: changeset)
    end
    {:noreply, socket}
  end

  def handle_event("try-join-room", %{"room" => room_id, "password" => password}, socket) do
    room = Chat.get_room!(room_id)
    socket = case Chat.join_room(room, socket.assigns.current_user.id, password) do
      {:ok, room} ->
        PubSub.broadcast(Tc.PubSub, Chat.rooms_topic(), {:chat_rooms, room})
        socket
      {:error, %Ecto.Changeset{} = changeset} -> assign(socket, changeset: changeset)
    end
    {:noreply, socket}
  end
end
