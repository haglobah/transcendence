defmodule TcWeb.ProfileLive do
  use TcWeb, :live_view

  alias Tc.Accounts
  alias Tc.Stats

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
      <.table id="matches" rows={@matches}>
        <:col :let={match} label="player_left"><%= match.player_left.name %></:col>
        <:col :let={match} label="score_left"><%= match.score_left %></:col>
        <:col :let={match} label="score_right"><%= match.score_right %></:col>
        <:col :let={match} label="player_right"><%= match.player_right.name %></:col>
      </.table>
    </div>
    """
  end

  def mount(%{"user_name" => user_name}, _session, socket) do
    profile = Accounts.get_user_by_name(user_name)
    matches = Stats.list_matches_for_user(profile.id)

    {:ok,
    socket
    |> assign(profile: profile)
    |> assign(matches: matches)
    }
  end
end
