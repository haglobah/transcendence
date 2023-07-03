defmodule TcWeb.ProfileLive.Component do
  use Phoenix.Component
  use TcWeb, :html

  attr :rank, :any
  def render_rank(assigns) do
  ~H"""
    <%= case @rank do %>
      <% :gold -> %>
        <img class="w-20 rounded-full" src={~p"/images/gold_icon.jpeg"}/>
      <% :silver -> %>
        <img class="w-20 rounded-full" src={~p"/images/silver_icon.jpeg"}/>
      <% :bronze -> %>
        <img class="w-20 rounded-full" src={~p"/images/bronze_icon.jpeg"}/>
    <% end %>
  """
  end
end
