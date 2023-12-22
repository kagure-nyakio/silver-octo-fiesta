defmodule InvoiceWeb.UserResetPasswordLive do
  use InvoiceWeb, :live_view

  alias Invoice.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto landing-grid">
      <div class="hidden md:block h-full bg-slate-300">
        <img src={~p"/images/landing_illustration.jpg"} alt="" class="h-full w-full object-cover" />
      </div>

      <div class="max-w-sm md:max-w-md">
        <h1 class="text-2xl text-[#252945] font-bold mb-7">
          Reset Password
        </h1>

        <.simple_form
          for={@form}
          id="reset_password_form"
          phx-submit="reset_password"
          phx-change="validate"
        >
          <.error :if={@form.errors != []}>
            Oops, something went wrong! Please check the errors below.
          </.error>

          <.input field={@form[:password]} type="password" label="New password" required />
          <.input
            field={@form[:password_confirmation]}
            type="password"
            label="Confirm new password"
            required
          />
          <:actions>
            <.button phx-disable-with="Resetting..." class="w-full">Reset Password</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(params, _session, socket) do
    socket = assign_user_and_token(socket, params)

    form_source =
      case socket.assigns do
        %{user: user} ->
          Accounts.change_user_password(user)

        _ ->
          %{}
      end

    {:ok, assign_form(socket, form_source), temporary_assigns: [form: nil]}
  end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def handle_event("reset_password", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: ~p"/login")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_password(socket.assigns.user, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_user_and_token(socket, %{"token" => token}) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "user"))
  end
end
