defmodule TcWeb.ChatLive.Component do
  use Phoenix.Component
  use TcWeb, :html

  alias Tc.Accounts

  attr :rooms, :list
  attr :user, :any
  def room_list(assigns) do
    ~H"""
    <div class="bg-sky-200">
      <%= for room <- @rooms do %>
        <.display_chat room={room} user={@user}/>
      <% end %>
    </div>
    <.link patch={~p"/chat/rooms/new"} phx-click={JS.push_focus()}>
      <.button>+</.button>
    </.link>
    """
  end

  attr :room, :any
  attr :user, :any
  def display_chat(assigns) do
    ~H"""
    <.link navigate={~p"/chat/rooms/#{@room.id}"}
               class={"flex items-center p-2"}>
      <%= if @room.name == nil do %>
        <% other_user = get_other(@room.members, @user) %>
        <.display_user user={other_user} />
      <% else %>
        <h3 class="ml-3"><%= @room.name %></h3>
        <p class="text-sm ml-3"><%= @room.description %></p>
      <% end %>
    </.link>
    """
  end

  def get_other(members, user) do
    [first, second] = Accounts.get_users(members)
    case first do
      ^user -> second
      _ -> first
    end
  end

  attr :room, :any
  slot :inner_block
  def display_room(assigns) do
    ~H"""
    <div class="flex justify-between bg-gray-200">
      <div class="flex items-center p-2">
        <h3 class="ml-3"><%= @room.name %></h3>
        <p class="text-sm ml-3"><%= @room.description %></p>
      </div>
      <div class="flex justify-end">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  attr :users, :list
  attr :is_admin, :boolean
  slot :inner_block
  def member_list(assigns) do
    ~H"""
    <div class="bg-gray-100 my-2 rounded w-80">
      <%= for user <- @users do %>
        <.display_user user={user}>
          <%= render_slot(@inner_block) %>
        </.display_user>
      <% end %>
    </div>
    """
  end

  attr :user, :any
  slot :inner_block
  def display_user(assigns) do
    ~H"""
    <div class="flex mx-2 py-2 justify-between">
      <div class="flex items-center">
        <.live_component module={ TcWeb.UserLiveComponent }
                         user={ @user }
                         id={ "user-#{@user.id}-status" }/>
        <h3 class="mx-2 text-lg"><%= @user.name %></h3>
        <p class="text-xs"><%= @user.id %></p>
      </div>
      <div class="flex">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
