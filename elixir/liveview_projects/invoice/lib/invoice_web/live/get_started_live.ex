defmodule InvoiceWeb.GetStartedLive do
  use InvoiceWeb, :live_view

  alias Invoice.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto landing-grid">
      <div class="hidden md:block h-full bg-slate-300">
        <img src={~p"/images/almost_there.png"} alt="" class="h-full w-full object-cover" />
      </div>

      <div class="mx-auto sm:mx-0 max-w-sm  sm:max-w-md py-2">
        <h1 class="text-2xl text-[#252945] font-bold mb-7">One more step</h1>
        <p>Fill in your address details</p>

        <.simple_form for={@form} id="address-form" phx-submit="save">
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>

          <.inputs_for :let={f} field={@form[:address]}>
            <.input
              field={f[:country]}
              type="select"
              label="Country"
              multiple={false}
              options={@countries}
              required
            />
            <.input field={f[:city]} type="text" label="City" required />
            <.input field={f[:street_address]} type="text" label="Street Address" required />
            <.input field={f[:postal_code]} type="text" label="Postal Code" required />
          </.inputs_for>

          <:actions>
            <.button phx-disable-with="Updating address..." class="w-full">Submit</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(_params, %{"user_token" => token} = _session, socket) do
    current_user = Accounts.get_user_by_session_token(token)
    changeset = Accounts.change_user(current_user)

    {:ok,
     socket
     |> assign(:trigger_submit, false)
     |> assign(:check_errors, false)
     |> assign(:countries, assign_countries())
     |> assign(:current_user, current_user)
     |> assign_form(changeset)}
  end

  def handle_event(
        "save",
        %{
          "address" => %{
            "address" => %{
              "city" => city,
              "country" => country,
              "postal_code" => postal_code,
              "street_address" => street_address
            }
          }
        } = _params,
        socket
      ) do
    address_attr = %{
      address: %{
        city: city,
        country: country,
        postal_code: postal_code,
        street_address: street_address
      }
    }

    %{assigns: %{current_user: user}} = socket

    with {:ok, _user} <- Accounts.update_user(user, address_attr) do
      {:noreply,
       socket
       |> put_flash(:info, "Address Updated")
       |> redirect(to: ~p"/")}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(check_errors: true)
         |> assign_form(changeset)}
    end
  end

  defp assign_countries() do
    Countries.all()
    |> Stream.map(&Map.get(&1, :name))
    |> Enum.to_list()
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "address")

    if changeset.valid? do
      socket
      |> assign(:form, form)
      |> assign(:check_errors, false)
    else
      assign(socket, :form, form)
    end
  end
end
