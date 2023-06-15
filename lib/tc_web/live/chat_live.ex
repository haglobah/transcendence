defmodule TcWeb.ChatLive do
  use TcWeb, :live_view


  def render(assigns) do
    ~H"""
    <div class="flex">
      <div class="h-[88vh] sticky top-14 w-52 overflow-y-scroll hidden md:block">
        <h3 class="text-xl">
          Here comes the chat list.
        </h3>
      </div>
    </div>
    """
  end

  def mount(%{"room_id" => room_id}, _session, socket) do
    {:ok,
      socket
      |> assign(active_room: room_id)
    }
  end

  def mount(_params, _session, socket) do
    {:ok,
      socket
      # |> assign(rooms: [room])
    }
  end
end
