defmodule TcWeb.HomeLive do
  use TcWeb, :live_view

  # alias Tc.Accounts

  @moduledoc """
  The home page one accesses when logged in.
  """

  def render(assigns) do
    ~H"""
    <div class="text-2xl my-10">
      <h2>This is <%= @current_user.name %>'s Home Page</h2>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
