defmodule TcWeb.ProfileLive do
  use TcWeb, :live_view

  alias Tc.Accounts
  alias Tc.Stats
  alias Tc.Activity
  alias Phoenix.PubSub

  import TcWeb.Component

  def render(assigns) do
    ~H"""
    <div class="flex h-[86vh]">
      <aside>
        <div class="w-80">
         <.user_avatar user={@profile} />
        </div>
        <h2 class="py-5 text-center text-2xl">
         <%= @profile.name %> | <%= @profile.email %>
        </h2>
      </aside>
      <div class="pl-20 w-full">
        <div class="flex justify-center pr-20">
          <.render_rank icon="gold_icon.jpeg"/>
          <div class="flex flex-col justify-center pl-5">
            <h5>
              Score:
            </h5>
            <text class="text-center">
            21 - 0
            </text>
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
