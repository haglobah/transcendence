defmodule TcWeb.ChatLive.PrivChatSearch do
  use TcWeb, :live_component

  import TcWeb.Component
  alias Tc.Chat
  alias Tc.Accounts
  alias Tc.Network
  alias Phoenix.PubSub

  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(assigns)
      |> assign(chattable_users: [])
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
            @chattable_users != [] &&
              "border-bottom-left-radius: 0; border-bottom-right-radius: 0; border-bottom: none"
          }
          aria-autocomplete="both"
          aria-controls="searchbox__results_list"
          autocomplete="off"
          autocorrect="off"
          autocapitalize="off"
          enterkeyhint="search"
          spellcheck="false"
          placeholder="Search for a user to chat with..."
          type="search"
          value=""
          tabindex="0"
        />
      </div>

      <div
        :if={@chattable_users != []}
        class="divide-y divide-slate-200 overflow-y-auto rounded-b-lg border-t border-slate-200 text-sm leading-6"
        id="searchbox__results_list"
        role="listbox"
      >
        <%= for user <- @chattable_users do %>
          <.display_user user={user} >
            <%= if room = Chat.get_privchat(@current_user.id, user.id) do %>
              <% IO.inspect(room) %>
              <.link navigate={~p"/chat/rooms/#{room.id}"}>
                <.button>
                  Jump to chat
                </.button>
              </.link>
            <% else %>
              <.button  phx-click="start-chat"
                        phx-value-other={user.id}
                        phx-target={@myself}>
                        Start Chat
              </.button>
            <% end %>
          </.display_user>
        <% end %>
      </div>
    </form>
    """
  end

  def handle_event("change", %{"search" => %{"query" => ""}}, socket) do
    {:noreply, assign(socket, chattable_users: [])}
  end

  def handle_event("change",
    %{"search" => %{"query" => search_query}},
    %{assigns: %{current_user: current_user}} = socket
  ) do
    blocked =
      current_user.id
      |> Network.list_blocked_users()
      |> Enum.map(fn u -> u.id end)
    except = [current_user.id | blocked]
    chattable_users = Accounts.search_users_except(%{query: search_query, except: except})
    {:noreply, assign(socket, chattable_users: chattable_users)}
  end

  def handle_event("start-chat", %{"other" => other}, socket) do
    socket = case Chat.create_privchat(%{"members" => [socket.assigns.current_user.id, other]}) do
      {:ok, room} ->
        PubSub.broadcast(Tc.PubSub, Chat.rooms_topic(), {:chat_rooms, room})
        socket
      {:error, %Ecto.Changeset{} = changeset} -> assign(socket, changeset: changeset)
    end
    {:noreply, socket}
  end
end
