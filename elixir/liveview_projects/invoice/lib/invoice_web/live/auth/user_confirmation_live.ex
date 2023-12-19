defmodule InvoiceWeb.UserConfirmationLive do
  use InvoiceWeb, :live_view

  alias Invoice.Accounts

  def mount(%{"token" => token}, _session, socket) do
    if connected?(socket) do
      send(self(), {:confirm_account, token})
    end

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""

    """
  end

  def handle_info({:confirm_account, token}, socket) do
    case Accounts.confirm_user(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> redirect(to: ~p"/get-started")}

      :error ->
        case socket.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/login")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "User confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/login")}
        end
    end
  end
end
