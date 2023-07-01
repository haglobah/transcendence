defmodule TcWeb.ProfileLive do
  use TcWeb, :live_view

  alias Tc.Accounts
  alias Tc.Stats
  alias Tc.Activity
  alias Phoenix.PubSub

  import TcWeb.Component

  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-2xl">
        <%= @profile.name %> | <%= @profile.email %>
      </h2>
      <div class="my-5">
        <.user_avatar user={@profile} />
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

    schedule_status_tick()

    {:ok,
    socket
    |> assign(profile: profile)
    |> assign(matches: matches)
    }
  end

  def handle_info(:status_tick, socket) do
    PubSub.broadcast(
      Tc.PubSub,
      Activity.status_topic(),
      {:change, socket.assigns.current_user.id, :online})
    schedule_status_tick()
    {:noreply, socket}
  end

  defp schedule_status_tick(), do: Process.send_after(self(), :status_tick, 1000)
end
