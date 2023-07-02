defmodule TcWeb.Component do
  use Phoenix.Component
  use TcWeb, :html

  attr :current_user, :any, default: nil
  attr :user, :any
  attr :socket, :any, default: nil
  attr :id, :string, default: ""
  attr :profile_link, :boolean, default: true
  slot :inner_block
  def display_user(assigns) do
    ~H"""
    <div class="flex mx-2 py-2 justify-between">
      <div class="flex items-center">
        <%= if @socket == nil do %>
          <div class="relative w-10 mx-2">
            <%= if @profile_link do %>
              <.link navigate={~p"/#{@user.name}"} >
                <.user_avatar user={@user}/>
              </.link>
            <% else %>
              <.user_avatar user={@user}/>
            <% end %>
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

  attr :user, :any
  def user_avatar(assigns) do
  ~H"""
  <%= if @user.avatar_upload do %>
    <img class="rounded-full" src={@user.avatar_upload}/>
  <% else %>
    <img class="rounded-full" src={~p"/images/default_avatar.png"}/>
  <% end %>
  """
  end

  attr :icon, :string
  def render_rank(assigns) do
  ~H"""
  <img class="w-20 rounded-full" src={~p"/images/#{@icon}"}/>
  """
  end
end
