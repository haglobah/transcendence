defmodule TcWeb.UserLive do
  use TcWeb, :inner_live_view

  alias TcWeb.Endpoint
  alias Tc.Activity

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

  def mount(_params, %{"live_user" => user} = _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(Activity.status_topic())
    end

    schedule_check()

    {:ok,
     socket
     |> assign(status: :offline)
     |> assign(last_change: System.monotonic_time())
     |> assign(user: user)
    }
  end

  def handle_info({:change, user_id, status} = _params, socket) do
    socket = case socket.assigns.user.id do
      ^user_id -> socket |> assign(status: status) |> assign(last_change: System.monotonic_time())
      _ -> socket
    end

    {:noreply, socket}
  end

  def handle_info(:check_tick, socket) do
    now = System.monotonic_time()
    delta_time = now - socket.assigns.last_change

    # IO.puts("Here")

    socket = if System.convert_time_unit(delta_time, :native, :second) > 2 do
      socket |> assign(status: :offline) |> assign(last_change: now)
    else
      socket
    end
    schedule_check()
    {:noreply, socket}
  end

  defp schedule_check(), do: Process.send_after(self(), :check_tick, 1000)
end
