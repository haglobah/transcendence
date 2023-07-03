defmodule TcWeb.ProfileLive do
  use TcWeb, :live_view

  alias Tc.Accounts
  alias Tc.Stats
  alias Tc.Activity
  alias Phoenix.PubSub

  import TcWeb.Component
  import TcWeb.ProfileLive.Component

  def render(assigns) do
    ~H"""
    <div class="flex h-[86vh]">
      <aside>
        <div class="w-80">
         <.user_avatar user={@user} />
        </div>
        <h2 class="py-5 text-center text-2xl">
         <%= @user.name %> | <%= @user.email %>
        </h2>
      </aside>
      <div class="pl-20 w-full">
        <div class="flex justify-center pr-20">
          <.render_rank rank={@stats.ladder}/>
          <div class="flex flex-col justify-center pl-5">
            <h5>
              Score:
            </h5>
            <p class="text-center">
              <%= @stats.wins %> - <%= @stats.draws %> - <%= @stats.losses %>
            </p>
          </div>
        </div>
        <.table id="matches" rows={@matches}>
          <:col :let={match} label="player_left"><%= match.player_left.name %></:col>
          <:col :let={match} label="score_left"><%= match.score_left %></:col>
          <:col :let={match} label="score_right"><%= match.score_right %></:col>
          <:col :let={match} label="player_right"><%= match.player_right.name %></:col>
        </.table>
      </div>
    </div>
    """
  end

  def mount(%{"user_name" => user_name}, _session, socket) do
    user = Accounts.get_user_by_name(user_name)
    matches = Stats.list_matches_for_user(user.id)

    stats = Stats.calculate_stats_for(user, matches)

    schedule_status_tick()

    {:ok,
    socket
    |> assign(user: user)
    |> assign(matches: matches)
    |> assign(stats: stats)
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
