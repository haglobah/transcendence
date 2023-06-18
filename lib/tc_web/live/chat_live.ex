defmodule TcWeb.ChatLive do
  use TcWeb, :live_view
  alias Tc.Chat

  import TcWeb.ChatLive.Component

  def render(assigns) do
    ~H"""
    <div id="mobile-sidenav" class="fixed bg-white overflow-y-scroll block md:hidden z-50 inset-0">
      <.room_list rooms={ @rooms }/>
    </div>
    <aside class="h-[88vh] sticky top-14 w-52 overflow-y-scroll hidden md:block">
      <.room_list rooms={ @rooms }/>
    </aside>
    """
  end

  # def mount(%{"room_id" => room_id}, _session, socket) do
  #   {:ok,
  #     socket
  #     |> assign(active_room: room_id)
  #   }
  # end

  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(rooms: Chat.list_rooms())
    }
  end

  def handle_params(%{"room_id" => room_id}, _session, %{assigns: assigns} = socket) do
    {:noreply,
    socket
    |> assign(rooms: assigns.rooms)
    |> assign(active_room: room_id)
    }
  end
  def handle_params(_params, _session, socket), do: {:noreply, socket}
end
