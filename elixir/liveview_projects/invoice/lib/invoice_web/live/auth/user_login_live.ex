defmodule InvoiceWeb.UserLoginLive do
  use InvoiceWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto landing-grid">
      <div class="hidden md:block h-full bg-slate-300">
        <img src={~p"/images/landing_illustration.jpg"} alt="" class="h-full w-full object-cover" />
      </div>
      <div class="max-w-sm md:max-w-md">
        <h1 class="text-2xl text-[#252945] font-bold mb-7">
          Sign in to generate invoices
        </h1>

        <.simple_form
          for={@form}
          id="login_form"
          action_class="w-full"
          action={~p"/login"}
          phx-update="ignore"
          >
          <.input field={@form[:email]} type="email" label="Email" required />
          <div class="grid gap-2">
            <.input field={@form[:password]} type="password" label="Password" required />
            <.link href={~p"/reset_password"} class="text-sm underline hover:text-brand">
              Forgot password?
            </.link>
          </div>
          <:actions>
            <.button phx-disable-with="Signing in..." class="w-full">
              Sign in <span aria-hidden="true">→</span>
            </.button>
            <p class="text-center mt-8">
              Don't have an account?
              <.link navigate={~p"/register"} class="font-semibold underline hover:text-brand">
                Sign up
              </.link>
            </p>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
