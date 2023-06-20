defmodule TcWeb.ChatLive.Component do
  use Phoenix.Component
  use TcWeb, :html

  attr :rooms, :list
  def room_list(assigns) do
    ~H"""
    <div class="bg-sky-200">
      <%= for room <- @rooms do %>
        <.link navigate={~p"/chat/rooms/#{room.id}"}
               class={"flex items-center p-2"}
        >
          <%!-- <.chat_icon /> --%>
          <h3 class="ml-3"><%= room.name %></h3>
          <p class="text-sm ml-3"><%= room.description %></p>
        </.link>
      <% end %>
    </div>
    <.link patch={~p"/chat/rooms/new"} phx-click={JS.push_focus()}>
      <.button>+</.button>
    </.link>
    """
  end

  attr :users, :list
  def user_list(assigns) do
    ~H"""
    <div class="">
      <%= for user <- @users do %>
        <div class="flex mx-2 my-2 items-center">
          <%= if user.avatar_upload do %>
            <div class="w-10 my-1 mx-2">
              <img class="rounded-full" src={user.avatar_upload}/>
            </div>
          <% end %>
          <h3 class="mx-2 text-lg"><%= user.name %></h3>
          <h3 class="mx-2 text-sm"><%= user.email %></h3>
        </div>
      <% end %>
    </div>
    """
  end
end
