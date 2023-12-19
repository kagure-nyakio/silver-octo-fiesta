defmodule Invoice.Accounts.UserAddress do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :city, :string
    field :country, :string
    field :street_address, :string
    field :postal_code, :string
  end

  def changeset(%__MODULE__{} = address, attrs \\ %{}) do
    address
    |> cast(attrs, [:city, :country, :street_address, :postal_code])
    |> validate_required([:city, :country, :street_address, :postal_code])
  end
end
