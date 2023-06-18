defmodule TcWeb.ChatLive.Chat do
  use Phoenix.Component
  use TcWeb, :html

  attr :messages, :any, required: true
  attr :page, :integer, required: true
  attr :start_of_messages?, :boolean, required: true

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
        <.message message={message} />
      </li>
    </ul>
    """
  end

  def message(assigns) do
    ~H"""
    <.message_meta message={@message} />
    <.message_content message={@message} />
    """
  end

  def message_meta(assigns) do
    ~H"""
    <dl class="-my-4 divide-y divide-zinc-100">
      <div class="flex gap-4 py-4 sm:gap-2">
        <%!-- <.user_icon /> --%>
        <dt class="w-1/8 flex-none text-[0.9rem] leading-8 text-zinc-500">
          <%= @message.sender_id %>
          <span>[<%= @message.inserted_at %>]</span>
          <%!-- <.delete_icon id={"message-#{@message.id}-buttons"} phx_click="delete_message" value={@message.id} /> --%>
        </dt>
      </div>
    </dl>
    """
  end

  def message_content(assigns) do
    ~H"""
    <dl class="-my-4 divide-y divide-zinc-100">
      <div class="flex gap-4 py-4 sm:gap-2">
        <dd class="text-sm leading-10 text-zinc-700">
          <%= @message.content %>
        </dd>
      </div>
    </dl>
    """
  end
end
