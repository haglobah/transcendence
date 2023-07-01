defmodule TcWeb.ChatLive.Messages do
  use Phoenix.Component
  use TcWeb, :html

  alias TcWeb.ChatLive.Component

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
        <Component.live_user id={@id} current_user={@current_user} user={@message.sender} socket={@socket}/>
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
