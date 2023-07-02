defmodule TcWeb.GameLive.Component do
  use Phoenix.Component

  attr :view_box, :string
  slot :inner_block, required: true
  def canvas(assigns) do
    ~H"""
    <svg class="m-auto max-w-3xl"
      viewBox={ @view_box }
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      phx-window-keydown="move"
      phx-window-keyup="stop"
      fill="black">
      <defs>
        <rect id="paddle" width="2" height="25"/>
        <rect id="ball" width="2" height="2"/>
      </defs>
      <rect width="100%" height="100%" fill="black"/>
      <%= render_slot(@inner_block) %>
    </svg>
    """
  end

  attr :view_box, :string
  slot :inner_block, required: true
  def game_over(assigns) do
    ~H"""
    <svg class="m-auto max-w-3xl"
      viewBox={ @view_box }
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      fill="black">
      <defs>
        <rect id="paddle" width="2" height="25"/>
        <rect id="ball" width="2" height="2"/>

      </defs>
      <rect width="100%" height="100%" fill="black"/>
      <%= render_slot(@inner_block) %>
      <text id="game_over"
            x="50%" y="50%"
            font-size="15"
            fill="lightgray"
            text-anchor="middle">GAME OVER</text>
    </svg>
    """
  end

  attr :x, :integer, required: true
  attr :y, :integer, required: true
  attr :color, :string
  def paddle(assigns) do
    ~H"""
    <use xlink:href="#paddle"
      x={ @x }
      y={ @y }
      fill={ "lightgray" }
      />
    """
  end

  attr :x, :integer, required: true
  attr :y, :integer, required: true
  attr :color, :string
  def ball(assigns) do
    ~H"""
    <use xlink:href="#ball"
      x={ @x }
      y={ @y }
      fill={ "lightgreen" }
      />
    """
  end

  attr :left, :integer, required: true
  attr :right, :integer, required: true
  def score(assigns) do
    ~H"""
    <text id="score_left"
      x="40%" y="15%"
      font-size="12"
      font-family="monospace"
      fill="lightgray"
      text-anchor="middle"
      dominant-baseline="middle"><%= @left %>
    </text>
    <text id="split_score"
      x="50%" y="15%"
      font-size="12"
      font-family="monospace"
      fill="lightgray"
      text-anchor="middle"
      dominant-baseline="middle">|
    </text>
    <text id="score_right"
      x="60%" y="15%"
      font-size="12"
      font-family="monospace"
      fill="lightgray"
      text-anchor="middle"
      dominant-baseline="middle"><%= @right %>
    </text>
    """
  end

  attr :seconds, :integer, required: true
  def clock(assigns) do
  ~H"""
  <text id="clock"
    x="50%" y="4%"
    font-size="4"
    font-family="monospace"
    fill="lightgray"
    text-anchor="middle"
    dominant-baseline="middle"><%= @seconds %></text>
  """
  end
end
