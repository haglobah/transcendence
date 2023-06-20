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
    <div class="bg-gray-100 my-2 rounded w-80">
      <%= for user <- @users do %>
        <.display_user user={user}/>
        <.button class="inline" phx-click="to_admin" phx-value-user_id={user.id}>Make an admin</.button>
      <% end %>
    </div>
    """
  end

  attr :user, :any
  def display_user(assigns) do
    ~H"""
    <div class="flex mx-2 py-2 items-center">
      <%= if @user.avatar_upload do %>
        <div class="w-10 mx-2">
          <img class="rounded-full" src={@user.avatar_upload}/>
        </div>
      <% end %>
      <h3 class="mx-2 text-lg"><%= @user.name %></h3>
    </div>
    """
  end
end
