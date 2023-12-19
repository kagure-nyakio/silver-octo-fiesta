defmodule InvoiceWeb.CustomComponents do
  @moduledoc """
  Provides modified core components from `StoryDeckWeb.CoreComponents`.
  """

  use Phoenix.Component

  import InvoiceWeb.Gettext

  alias Phoenix.LiveView.JS

  @doc """
  Renders flash notices.

  ## Examples

      <.custom_flash kind={:info} custom_flash={@custom_flash} />
      <.custom_flash kind={:info} phx-mounted={show("#custom_flash")}>Welcome Back!</.custom_flash>
  """
  attr(:id, :string, default: "custom_flash", doc: "the optional id of flash container")
  attr(:flash, :map, default: %{}, doc: "the map of flash messages to display")
  attr(:title, :string, default: nil)
  attr(:kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup")
  attr(:rest, :global, doc: "the arbitrary HTML attributes to add to the flash container")

  slot(:inner_block, doc: "the optional inner block that renders the flash message")

  @spec custom_flash(map()) :: Phoenix.LiveView.Rendered.t()
  def custom_flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "alert",
        @kind == :info && "bg-[#7c5dfa] text-white p-2 flex flex-col justify-center",
        @kind == :error && "bg-[#EC5757] text-white p-2 flex flex-col justify-center"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <.icon :if={@kind == :info} name="hero-information-circle-mini" class="h-4 w-4" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="h-4 w-4" />
        <%= @title %>
      </p>
      <p class="mt-2 text-sm leading-5"><%= msg %></p>
      <button type="button" class="group absolute top-1 right-1 p-2" aria-label={gettext("close")}>
        <.icon name="hero-x-mark-solid" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.custom_flash_group flash={@flash} />
  """
  attr(:flash, :map, required: true, doc: "the map of flash messages")

  @spec custom_flash_group(map()) :: Phoenix.LiveView.Rendered.t()
  def custom_flash_group(assigns) do
    ~H"""
    <.custom_flash kind={:info} flash={@flash} />
    <.custom_flash kind={:error} flash={@flash} />
    """
  end

  defp hide(js, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  attr(:name, :string, required: true)
  attr(:class, :string, default: nil)

  defp icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
