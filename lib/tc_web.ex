defmodule TcWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use TcWeb, :controller
      use TcWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def static_paths,
    do: ~w(css fonts images js favicon.ico robots.txt 502.html maintenance.html
        apple-touch android-chrome browserconfig manifest.json mstile
        safari-pinned-tab.svg)

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import TcWeb.Gettext
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: TcWeb.Layouts]

      import Plug.Conn
      import TcWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {TcWeb.Layouts, :app}

      def handle_event("enqueue", _params, socket) do
        TcWeb.Endpoint.subscribe(Tc.Queue.topic())
        Tc.Queue.enqueue(socket.assigns.current_user, false)
        {:noreply, socket}
      end

      def handle_event("enqueue-fast", _params, socket) do
        TcWeb.Endpoint.subscribe(Tc.Queue.topic())
        Tc.Queue.enqueue(socket.assigns.current_user, true)
        {:noreply, socket}
      end

      def handle_info({:queue, left, right, game_id}, socket) do
        if socket.assigns.current_user == left
        || socket.assigns.current_user == right do
          TcWeb.Endpoint.unsubscribe(Tc.Queue.topic())
          {:noreply, push_navigate(socket, to: "/game/#{game_id}")}
        else
          {:noreply, socket}
        end
      end

      unquote(html_helpers())
    end
  end

  def inner_live_view do
    quote do
      use Phoenix.LiveView

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import TcWeb.CoreComponents
      import TcWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: TcWeb.Endpoint,
        router: TcWeb.Router,
        statics: TcWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
