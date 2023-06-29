defmodule TcWeb.HomeLive.Component do
  use Phoenix.Component
  use TcWeb, :html

  import TcWeb.ChatLive.Component

  attr :relations, :list
  def relation_list(assigns) do
    ~H"""
    <div class="flex flex-col">
      <%= for r <- @relations do %>
        <.display_user user={r} />
      <% end %>
    </div>
    """
  end

  attr :relations, :list
  attr :current_user, :any
  def pending_list(assigns) do
    ~H"""
    <div class="flex flex-col">
      <%= for {req, rec} <- @relations do %>
        <%= if req.id == @current_user.id do %>
          <.display_user user={rec}>
            <p class="text-xs">Friend request send - waiting for response...</p>
          </.display_user>
        <% else %>
          <.display_user user={req}>
            <.link class="mx-1" patch={~p"/friend/accept"} phx-click={JS.push_focus()}>
              <.button>Accept friend request</.button>
            </.link>
          </.display_user>
        <% end %>
      <% end %>
    </div>
    """
  end
end
