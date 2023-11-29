defmodule Invoice.Accounts.UserAddress do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :city, :string
    field :country, :string
    field :street_address, :string
    field :post_code, :string
  end

  def changeset(address, attrs) do
    address
    |> cast(attrs, [:city, :country, :street_address, :post_code])
    |> validate_required([:city, :country, :street_address, :post_code])
  end
end
