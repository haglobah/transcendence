defmodule TcWeb.Router do
  use TcWeb, :router

  import TcWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TcWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  ## Standard Routes

  scope "/", TcWeb do
    pipe_through :browser

  end

  ## Authentication routes

  scope "/", TcWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
    on_mount: [{TcWeb.UserAuth, :redirect_if_user_is_authenticated}] do

      live "/", MainLive
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", TcWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{TcWeb.UserAuth, :ensure_authenticated}] do

        live "/users/settings", UserSettingsLive, :edit
        live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

        live "/home", HomeLive
        live "/friend/new", HomeLive, :new
        live "/game/:game_id", GameLive
        live "/game/:game_id/game_over", GameLive, :game_over

        live "/chat/rooms/", ChatLive, :index
        live "/chat/rooms/new", ChatLive, :new
        live "/chat/rooms/:room_id", ChatLive, :show
        live "/chat/rooms/:room_id/edit", ChatLive, :edit
        live "/chat/rooms/:room_id/join", ChatLive, :join

        live "/:user_name", ProfileLive
    end
  end

  scope "/", TcWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{TcWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  # Enables LiveDashboard only for development.
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: TcWeb.Telemetry
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:new, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TcWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
