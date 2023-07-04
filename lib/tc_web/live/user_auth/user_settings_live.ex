defmodule TcWeb.UserSettingsLive do
  use TcWeb, :live_view

  alias Tc.Accounts
  alias Tc.Accounts.Mfa

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Account Settings
      <:subtitle>Manage your account email address and password settings</:subtitle>
    </.header>
    <div class="w-1/2 mx-auto">
      <div>
        <h2 class="text-2xl my-5">
          <%= @current_user.name %>
        </h2>
        <img
          alt="user_avatar" width="200"
          src={@current_user.avatar_upload}
          />
      </div>

      <div class="space-y-12 divide-y">
        <.simple_form
          for={@name_form}
          id="name_form"
          phx-submit="update_name"
          phx-change="validate_name"
        >
          <.input field={@name_form[:name]} type="text" label="name" required />
          <.input
            field={@name_form[:current_password]}
            name="current_password"
            id="current_password_for_name"
            type="password"
            label="Current password"
            value={@name_form_current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Email</.button>
          </:actions>
        </.simple_form>
        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
        >
          <.input field={@email_form[:email]} type="email" label="Email" required />
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="password"
            label="Current password"
            value={@email_form_current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Email</.button>
          </:actions>
        </.simple_form>
        <.simple_form :if={!@is_2fa}
          for={@password_form}
          id="password_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <.input
            field={@password_form[:email]}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <.input field={@password_form[:password]} type="password" label="New password" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirm new password"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Current password"
            id="current_password_for_password"
            value={@current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Password</.button>
          </:actions>
        </.simple_form>
        <.button :if={@is_2fa} phx-click={show_modal("totp-modal")}>
          Change your password
        </.button>
        <.button :if={!@is_2fa} phx-click={show_modal("create-mfa-modal")}>
          Add Two-factor Authentication
        </.button>
      </div>
    </div>

    <.modal id="totp-modal">
      <.simple_form
        for={@totp_form}
        id="totp_form"
        phx-submit="check_totp"
        phx-trigger-action={@trigger_submit}
      >
        <.input field={@totp_form[:code]} type="text" label="One-time code" required />
        <:actions>
          <.button phx-disable-with="Checking...">Check Code</.button>
        </:actions>
      </.simple_form>
    </.modal>
    <.modal id="change-mfa-password-modal">
      <.simple_form
        for={@password_form}
        id="password_form"
        action={~p"/users/log_in?_action=password_updated"}
        method="post"
        phx-change="validate_password"
        phx-submit="update_password"
        phx-trigger-action={@trigger_submit}
      >
        <.input
          field={@password_form[:email]}
          type="hidden"
          id="hidden_user_email"
          value={@current_email}
        />
        <.input field={@password_form[:password]} type="password" label="New password" required />
        <.input
          field={@password_form[:password_confirmation]}
          type="password"
          label="Confirm new password"
        />
        <.input
          field={@password_form[:current_password]}
          name="current_password"
          type="password"
          label="Current password"
          id="current_password_for_password"
          value={@current_password}
          required
        />
        <:actions>
          <.button phx-disable-with="Changing...">Change Password</.button>
        </:actions>
      </.simple_form>
    </.modal>

    <.modal id="create-mfa-modal">
      <div>
        <.simple_form
          for={@mfa_form}
          id="mfa_form"
          phx-submit="create_mfa"
          phx-trigger-action={@trigger_submit}
        >
          <.input
            field={@mfa_form[:email]}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <.input
            field={@mfa_form[:otp_secret]}
            type="hidden"
            id="hidden_otp_secret"
            value={@otp_secret}
          />
          <%= Mfa.generate_qrcode(@otp_uri) %>
          <.input
            field={@mfa_form[:otp_code]}
            name="otp_code"
            type="text"
            label="One-time code"
            id="otp_code_for_mfa"
            value={@otp_code}
            required
          />
          <:actions>
            <.button phx-disable-with="Adding...">Add Two-factor Authentication </.button>
          </:actions>
        </.simple_form>
      </div>
    </.modal>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    name_changeset = Accounts.change_user_name(user)
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    mfa_changeset = Accounts.change_create_mfa(user)
    totp_changeset = Accounts.change_totp(user)
    otp_secret = NimbleTOTP.secret()
    otp_uri = Mfa.generate_uri(user.name, otp_secret)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:is_2fa, user.is_2fa)
      |> assign(:otp_uri, otp_uri)
      |> assign(:otp_secret, Base.encode64(otp_secret))
      |> assign(:otp_code, nil)
      |> assign(:name_form_current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_name, user.name)
      |> assign(:current_email, user.email)
      |> assign(:name_form, to_form(name_changeset))
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:mfa_form, to_form(mfa_changeset))
      |> assign(:totp_form, to_form(totp_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_name", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    name_form =
      socket.assigns.current_user
      |> Accounts.change_user_name(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, name_form: name_form, name_form_current_password: password)}
  end

  def handle_event("update_name", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_name(user, password, user_params) do
      {:ok, _updated_user} ->

        info = "You have successfully changed your username"
        {:noreply, socket |> put_flash(:info, info) |> assign(name_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :name_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("create_mfa",
    %{"otp_code" => otp_code, "user" => %{"otp_secret" => otp_secret}},
    socket
  ) do
    user = socket.assigns.current_user
    mfa_attrs = %{code: otp_code, otp_secret: otp_secret}

    case Accounts.add_mfa(user, mfa_attrs) do
      {:ok, user} ->
        IO.inspect(user)
        {:noreply, assign(socket, trigger_submit: true)}
      {:error, changeset} ->
        IO.inspect(changeset)
        {:noreply, assign(socket, mfa_form: to_form(changeset))}
    end

    {:noreply, socket}
  end

  def handle_event("check_totp",
    %{"user" => %{"code" => code}} = params,
    socket
  ) do

    IO.inspect(params)
    user = socket.assigns.current_user
    totp_attrs = %{code: code}

    case Accounts.change_totp(user, totp_attrs) do
      %Ecto.Changeset{} = changeset ->
        IO.inspect(user)
        show_modal("change-mfa-password-modal")
        {:noreply, socket}
      {:error, changeset} ->
        IO.inspect(changeset)
        {:noreply, assign(socket, totp_form: to_form(changeset))}
    end

    {:noreply, socket}
  end
end
