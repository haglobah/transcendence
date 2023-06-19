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
end
