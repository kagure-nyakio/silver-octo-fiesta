defmodule InvoiceWeb.UserRegistrationLive do
  use InvoiceWeb, :live_view

  alias Invoice.Accounts
  alias Invoice.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto landing-grid">
      <div class="hidden md:block h-full bg-slate-300">
        <img src={~p"/images/landing_illustration.jpg"} alt="" class="h-full w-full object-cover" />
      </div>

      <div class="max-w-sm md:max-w-md">
        <h1 class="text-2xl text-[#252945] font-bold mb-7">
          Sign up to generate invoices
        </h1>

        <.simple_form
          for={@form}
          id="registration_form"
          phx-submit="save"
          phx-change="validate"
          phx-trigger-action={@trigger_submit}
          action={~p"/login?_action=registered"}
          method="post"
          action_class="w-full"
        >
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>

          <.input field={@form[:username]} type="text" label="Username" required />
          <.input field={@form[:email]} type="email" label="Email" required />
          <.input field={@form[:password]} type="password" label="Password" required />

          <:actions>
            <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
            <p class="text-center text-sm mt-2">
              Already have an account?
              <.link navigate={~p"/login"} class="font-semibold underline hover:text-brand">
                Sign in
              </.link>
            </p>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
