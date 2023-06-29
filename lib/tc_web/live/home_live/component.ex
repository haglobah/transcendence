defmodule TcWeb.HomeLive.Component do
  use Phoenix.Component

  import TcWeb.ChatLive.Component

  attr :friends, :list
  def friend_list(assigns) do
    ~H"""
    <div class="flex flex-col">
      <%= for f <- @friends do %>
        <.display_user user={f} />
      <% end %>
    </div>
    """
  end
end
