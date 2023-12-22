defmodule InvoiceWeb.UserForgotPasswordLive do
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
          Forgot Password?
        </h1>

        <p>
          Enter the email address you used when you joined and we’ll send you instructions to reset your password.
        </p>

        <p class="mt-8">
          For security reasons, we do NOT store your password. So rest assured that we will never send your password via email.
        </p>

        <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
          <.input field={@form[:email]} type="email" placeholder="Email" required />
          <:actions>
            <.button phx-disable-with="Sending..." class="w-full">
              Send reset instructions
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/reset_password/#{&1}")
      )
    end

    info =
      "If this email address was used to create an account, instructions to reset your password will be sent to you. Please check your email."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/login")}
  end
end
