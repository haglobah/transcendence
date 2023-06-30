defmodule TcWeb.UserLiveComponent do
  use TcWeb, :live_component

  alias TcWeb.Endpoint
  alias Tc.Activity

  def update(assigns, socket) do
    if connected?(socket) do
      Endpoint.subscribe(Activity.status_topic())
    end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(status: :offline)
    }
  end

  def render(assigns) do
    ~H"""
    <div class="relative w-10 mx-2">
      <img class="rounded-full" src={@user.avatar_upload}/>
      <%= case @status do %>
        <% :online -> %>
          <span class="absolute w-3 h-3 rounded-full bg-green-500 border-2 border-white top-0 right-0"></span>
        <% :in_game -> %>
          <span class="absolute w-3 h-3 rounded-full bg-yellow-400 border-2 border-white top-0 right-0"></span>
        <% :offline -> %>
          <span class="absolute w-3 h-3 rounded-full bg-gray-300 border-2 border-white top-0 right-0"></span>
        <% :away -> %>
          <span class="absolute w-3 h-3 rounded-full bg-red-500 border-2 border-white top-0 right-0"></span>
      <% end %>
    </div>
    """
  end

  def handle_info({:status_change, user_id, status}, socket) do
    socket = case socket.assigns.user.id do
      ^user_id -> assign(socket, status: status)
      _ -> socket
    end

    {:noreply, socket}
  end
end
