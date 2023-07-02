defmodule TcWeb.ChatLive.Component do
  use Phoenix.Component
  use TcWeb, :html

  alias Tc.Accounts
  import TcWeb.Component

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
        <.display_user user={other_user} profile_link={false} />
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

  attr :current_user, :any
  attr :socket, :any
  attr :messages, :any, required: true
  attr :page, :integer, required: true
  attr :start_of_messages?, :boolean, required: true
  attr :members, :list, required: true

  def list_messages(assigns) do
    ~H"""
    <span
      :if={@page > 1}
      class="text-3xl fixed bottom-2 right-2 bg-zinc-900 text-white rounded-lg p-3 text-center min-w-[65px] z-50 opacity-80"
      >
      <span class="text-sm">pg</span>
      <%= @page %>
    </span>

    <div :if={@start_of_messages?} class="mt-5 text-[50px] text-center">
      🎉 You made it to the beginning of time 🎉
    </div>
    <ul
      id="activity"
      phx-update="stream"
      phx-viewport-top={!@start_of_messages? && "next-page"}
      phx-viewport-bottom={@page > 1 && "prev-page"}
      phx-page-loading
      class={[
        if(@start_of_messages?, do: "pb-10", else: "pt-[calc(50vh)]"),
        if(@page == 1, do: "pt-10", else: "pb-[calc(50vh)]")
      ]}
    >
      <li :for={{id, message} <- @messages} id={id}>
        <.message message={message} current_user={@current_user} socket={@socket} id={id}/>
      </li>
    </ul>
    """
  end

  attr :id, :string
  attr :message, :any
  attr :current_user, :any
  attr :socket, :any
  def message(assigns) do
    ~H"""
    <div class="flex mx-2 py-2">
      <div class="w-12">
        <.live_user id={@id} current_user={@current_user} user={@message.sender} socket={@socket}/>
      </div>
      <div class="flex mx-3 flex-col">
        <div class="flex my-2 items-center">
          <h3 class="font-medium"><%= @message.sender.name %></h3>
          <span class="text-xs mx-2 text-zinc-500"><%= @message.inserted_at %></span>
        </div>
        <div class="text-sm text-zinc-700">
          <%= @message.content %>
        </div>
      </div>
    </div>
    """
  end
end
