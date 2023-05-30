defmodule TcWeb.UserSettingsLive do
  use TcWeb, :live_view

  alias Tc.Accounts

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Account Settings
      <:subtitle>Manage your account email address and password settings</:subtitle>
    </.header>

    <div>
      <h2 class="text-2xl my-5">
        <%= @current_user.name %>
      </h2>
      <img
        alt="user_avatar" width="200"
        src={@current_user.avatar_upload}
        />
      <.simple_form
        for={@avatar_form}
        multipart
        id="avatar_form"
        phx-submit="update_avatar"
      >
        <div phx-drop-target={ @uploads.image.ref}>
          <label>Avatar</label>
          <.live_file_input upload={ @uploads.image} />
        </div>
        <:actions>
          <.button phx-disable-with="Changing...">Change Avatar</.button>
        </:actions>
      </.simple_form>
      <%= for image <- @uploads.image.entries do %>
        <div class="mt-4">
          <.live_img_preview entry={image} width="60" />
        </div>
        <progress value={image.progress} max="100" />
        <%= for err <- upload_errors(@uploads.image, image) do %>
          <.error><%= err %></.error>
        <% end %>
      <% end %>
    </div>

    <div class="space-y-12 divide-y">
      <div>
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
            <.button phx-disable-with="Changing...">Change Username</.button>
          </:actions>
        </.simple_form>
      </div>
      <div>
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
      </div>
      <div>
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
      </div>
    </div>
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
    avatar_changeset = Accounts.change_user_avatar(user)
    name_changeset = Accounts.change_user_name(user)
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:name_form_current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_avatar_upload, user.avatar_upload)
      |> assign(:current_name, user.name)
      |> assign(:current_email, user.email)
      |> assign(:avatar_form, to_form(avatar_changeset))
      |> assign(:name_form, to_form(name_changeset))
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)
      |> allow_upload(:image,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1,
        max_file_size: 9_000_000,
        auto_upload: true)

    {:ok, socket}
  end

  def handle_event("update_avatar", %{"user" => user_params}, socket) do
    user_params = params_with_image(socket, user_params)
    user = socket.assigns.current_user

    case Accounts.update_user_avatar(user, user_params) do
      {:ok, _updated_user} ->

        info = "You have successfully changed your avatar"
        {:noreply, socket |> put_flash(:info, info)}

      {:error, changeset} ->
        {:noreply, assign(socket, :avatar_form, to_form(Map.put(changeset, :action, :insert)))}
    end
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

  def params_with_image(socket, params) do
    path =
      socket
      |> consume_uploaded_entries(:image, &upload_static_file/2)
      |> List.first()

    Map.put(params, "avatar_upload", path)
  end

  defp upload_static_file(%{path: path}, _entry) do
    # Real image persistence
    filename = Path.basename(path)
    dest = Path.join("priv/static/images", filename)
    File.cp!(path, dest)

    {:ok, ~p"/images/#{filename}"}
  end
end
