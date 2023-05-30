defmodule TcWeb.ProfileLive do
  use TcWeb, :live_view

  alias Tc.Accounts

  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-2xl">
        <%= @profile.name %> | <%= @profile.email %>
      </h2>
      <div class="my-5">
      <%= if @profile.avatar_upload do %>
        <img src={@profile.avatar_upload}/>
      <% end %>
      </div>
    </div>
    """
  end

  def mount(%{"user_name" => user_name}, _session, socket) do
    profile = Accounts.get_user_by_name(user_name)

    {:ok,
    socket
    |> assign(profile: profile)
    }
  end
end
