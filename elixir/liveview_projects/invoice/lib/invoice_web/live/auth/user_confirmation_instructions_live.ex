defmodule InvoiceWeb.UserConfirmationInstructionsLive do
  use InvoiceWeb, :live_view

  alias Invoice.Accounts

  def render(assigns) do
    ~H"""
    <div class="bg-[#f8f8fb] grid min-h-[100svh] justify-center items-center">
      <div class="grid gap-5 bg-[#DFE3FA] px-8 py-10 w-[80%] mx-auto rounded-xl max-w-xl">
        <h1 class="text-2xl font-bold">
          Confirm your Email
        </h1>
        <p>
          <span class="inline-block mb-1">
            We've sent a confirmation email to <span class="text-[#7c5dfa] underline"><%= @user.email %></span>.
          </span>
          <span class="inline-block mb-1">
            Please follow the link in the message to confirm your email address.
          </span>
          <span class="inline-block mb-1">
            If you did not receive the email, please check your spam folder or:
          </span>
        </p>
        <.button
          phx-disable-with="Sending..."
          class="w-full"
          phx-click="send_instructions"
          phx-value-email={@user.email}
        >
          Resend confirmation instructions
        </.button>
      </div>
    </div>
    """
  end

  def mount(_params, %{"user_token" => user_token} = _Ssession, socket) do
    {
      :ok,
      assign(socket, :user, Accounts.get_user_by_session_token(user_token))
    }
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/confirm/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)}
  end
end
