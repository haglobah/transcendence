defmodule TcWeb.ChatLive.PrivChatSearch do
  use TcWeb, :live_component

  import TcWeb.ChatLive.Component
  alias Tc.Chat
  alias Tc.Accounts
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
            <%= if is_blocked(@current_user, user) do %>
              <.button  phx-click="unblock-user"
                        phx-value-other={user.id}
                        phx-target={@myself}>
                        Unblock user
              </.button>
            <% else %>
              <.button  phx-click="start-chat"
                        phx-value-other={user.id}
                        phx-target={@myself}>
                        Start Chat
              </.button>
              <.button  phx-click="block-user"
                        phx-value-other={user.id}
                        phx-target={@myself}>
                        Block from chatting
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
    %{assigns: %{current_user: current_user}} = socket) do

    except = [current_user.id] #| current_user.blocked]
    chattable_users = Accounts.search_users_except(%{query: search_query, except: except})
    {:noreply, assign(socket, chattable_users: chattable_users)}
  end

  def handle_event("start-chat", %{"other" => other}, socket) do
    socket = case Chat.create_privchat(%{"members" => [socket.assigns.current_user, other]}) do
      {:ok, room} ->
        PubSub.broadcast(Tc.PubSub, Chat.rooms_topic(), {:chat_rooms, room})
        :timer.sleep(1000)
        socket
      {:error, %Ecto.Changeset{} = changeset} -> assign(socket, changeset: changeset)
    end
    {:noreply, socket}
  end

  def handle_event("block-user", %{"current" => _user_id}, socket) do
    # socket = change_relation(&Chat.block_user/2, user_id, socket)
    {:noreply, socket}
  end

  def handle_event("unblock-user", %{"current" => _user_id}, socket) do
    # socket = change_relation(&Chat.unblock_user/2, user_id, socket)
    {:noreply, socket}
  end

  # defp change_relation(change_fun, member_id, socket) do
  #   case change_fun.(socket.assigns.room, member_id) do
  #     {:ok, room} ->
  #       PubSub.broadcast(Tc.PubSub, Chat.rooms_topic(), {:edit_room})
  #       assign(socket, room: room)
  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       assign(socket, changeset: changeset)
  #   end
  # end

  defp is_blocked(_current_user, _user) do
    # case current_user.blocked do
    #   nil -> false
    #   [] -> false
    #   [_ | _] -> user.id in current_user.blocked
    # end
    false
  end
end
