defmodule TcWeb.ChatLive.UserSearch do
  use TcWeb, :live_component

  alias Tc.Chat
  alias Tc.Accounts

  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(assigns)
      |> assign(addable_users: [])
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
            @addable_users != [] &&
              "border-bottom-left-radius: 0; border-bottom-right-radius: 0; border-bottom: none"
          }
          aria-autocomplete="both"
          aria-controls="searchbox__results_list"
          autocomplete="off"
          autocorrect="off"
          autocapitalize="off"
          enterkeyhint="search"
          spellcheck="false"
          placeholder="Add a member..."
          type="search"
          value=""
          tabindex="0"
        />
      </div>

      <ul
        :if={@addable_users != []}
        class="divide-y divide-slate-200 overflow-y-auto rounded-b-lg border-t border-slate-200 text-sm leading-6"
        id="searchbox__results_list"
        role="listbox"
      >
        <%= for user <- @addable_users do %>
          <li id={"#{user.id}"}>
            <.button  phx-click="add-user"
                      phx-value-room={@room.id}
                      phx-value-user={user.id}
                      phx-target={@myself}>
              <%= user.name %>
            </.button>
          </li>
        <% end %>
      </ul>
    </form>
    """
  end

  def handle_event("change", %{"search" => %{"query" => ""}}, socket) do
    {:noreply, assign(socket, addable_users: [])}
  end
  def handle_event("change",
    %{"search" => %{"query" => search_query}},
    %{assigns: %{room: room}} = socket) do
    except =
      case room.blocked do
        nil -> room.members
        _ -> room.members ++ room.blocked
      end
    addable_users = Accounts.search_addable_users(%{query: search_query, except: except})
    {:noreply, assign(socket, addable_users: addable_users)}
  end

  def handle_event("add-user", %{"user" => user_id}, socket) do
    socket = case Chat.add_member(socket.assigns.room, user_id) do
      {:ok, room} ->
        assign(socket, room: room)
      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, changeset: changeset)
    end

    {:noreply, socket}
  end
end
