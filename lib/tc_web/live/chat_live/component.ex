defmodule TcWeb.ChatLive.Component do
  use Phoenix.Component
  use TcWeb, :html

  alias Tc.Accounts

  attr :rooms, :list
  attr :user, :any
  attr :active_room, :any, default: nil
  def room_list(assigns) do
    ~H"""
    <div class="flex flex-col h-[86vh] bg-white rounded-lg justify-between">
      <div class="space-y-6 lg:space-y-2 border-l border-slate-100 dark:border-slate-800">
        <h5 class="mb-8 lg:mb-3 font-semibold text-slate-900 dark:text-slate-200"> Chat Rooms </h5>
        <%= for room <- @rooms do %>
          <%= if room == @active_room do %>
            <.display_chat room={room} user={@user} active={true}/>
          <% else %>
            <.display_chat room={room} user={@user}/>
          <% end %>
        <% end %>
      </div>
      <div class="py-4 px-10">
        <.link patch={~p"/chat/rooms/new"} phx-click={JS.push_focus()}>
          <.button>+</.button>
        </.link>
      </div>
    </div>
    """
  end

  attr :room, :any
  attr :user, :any
  attr :active, :boolean, default: false
  def display_chat(assigns) do
    ~H"""
    <.link navigate={~p"/chat/rooms/#{@room.id}"}
               class={"block border-l -ml-px dark:hover:border-slate-500
                      dark:text-slate-400 dark:hover:text-slate-300" <>
                      if @active do " text-sky-500/100 border-sky-500/100 pl-5"
                      else " text-slate-700 border-transparent hover:border-slate-400 pl-4" end}>
      <%= if @room.name == nil do %>
        <% other_user = get_other(@room.members, @user) %>
        <.display_user user={other_user} />
      <% else %>
        <h3 class="o-underline ml-3"><%= @room.name %></h3>
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
    <div class="flex justify-between bg-gray-300">
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

  attr :current_user, :any, default: nil
  attr :user, :any
  attr :socket, :any, default: nil
  attr :id, :string, default: ""
  slot :inner_block
  def display_user(assigns) do
    ~H"""
    <div class="flex mx-2 py-2 justify-between">
      <div class="flex items-center">
        <%= if @socket == nil do %>
          <div class="relative w-10 mx-2">
            <img class="rounded-full" src={@user.avatar_upload} />
          </div>
        <% else %>
          <.live_user id={@id} current_user={@current_user} user={@user} socket={@socket}/>
        <% end %>
        <h3 class="mx-2 text-lg"><%= @user.name %></h3>
        <p class="text-xs"><%= @user.id %></p>
      </div>
      <div class="flex">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  def live_user(assigns) do
  ~H"""
  <%= live_render(@socket,
              TcWeb.UserLive,
              [id: "user-#{@user.id}-status" <> @id,
              session: %{"live_user" => @user,
                          "current_user" => @current_user}]) %>
  """
  end
end
