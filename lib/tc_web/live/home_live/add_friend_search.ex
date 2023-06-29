defmodule TcWeb.HomeLive.AddFriendSearch do
  use TcWeb, :live_component

  import TcWeb.ChatLive.Component
  alias Phoenix.PubSub
  alias Tc.Network
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

      <div
        :if={@addable_users != []}
        class="divide-y divide-slate-200 overflow-y-auto rounded-b-lg border-t border-slate-200 text-sm leading-6"
        id="searchbox__results_list"
        role="listbox"
      >
        <%= for user <- @addable_users do %>
          <.display_user user={user} >
            <%= if Network.is_blocked(@current_user, user) do %>
              <.button  phx-click="unblock-user"
                        phx-value-user={user.id}
                        phx-target={@myself}>
                        Unblock user
              </.button>
            <% else %>
              <.button  phx-click="befriend-user"
                        phx-value-user={user.id}
                        phx-target={@myself}>
                        Send friend request
              </.button>
              <.button  phx-click="block-user"
                        phx-value-user={user.id}
                        phx-target={@myself}>
                        Block User
              </.button>
            <% end %>
          </.display_user>
        <% end %>
      </div>
    </form>
    """
  end

  def handle_event("change", %{"search" => %{"query" => ""}}, socket) do
    {:noreply, assign(socket, addable_users: [])}
  end
  def handle_event("change",
    %{"search" => %{"query" => search_query}},
    socket) do

    addable_users = Accounts.search_users_except(%{query: search_query, except: []})
    {:noreply, assign(socket, addable_users: addable_users)}
  end

  def handle_event("befriend-user", %{"user" => user_id}, socket) do
    socket = change_room(&Network.send_friend_request/2, user_id, socket)
    {:noreply, socket}
  end

  def handle_event("block-user", %{"user" => user_id}, socket) do
    socket = change_room(&Network.block_user/2, user_id, socket)
    {:noreply, socket}
  end

  def handle_event("unblock-user", %{"user" => user_id}, socket) do
    socket = change_room(&Network.unblock_user/2, user_id, socket)
    {:noreply, socket}
  end

  defp change_room(change_fun, member_id, socket) do
    case change_fun.(socket.assigns.room, member_id) do
      {:ok, relation} ->
        PubSub.broadcast(Tc.PubSub, Network.relation_topic(), {:change_relation})
        socket
      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, changeset: changeset)
    end
  end
end
