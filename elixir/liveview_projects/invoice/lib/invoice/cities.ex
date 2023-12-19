defmodule Invoice.Cities do
  @moduledoc """
  Returns information about cities and cities
  """

  use Agent

  def start_link(_) do
    Agent.start_link(&cities/0, name: __MODULE__)
  end

  # TODO: use same list for countries
  def get_cities_by_country(country) do
    Agent.get(__MODULE__, &filter_by_country(&1, country))
  end

  # def get_countries do
  #   Agent.get(__MODULE, &fetch_countries/0)
  # end

  def cities do
    :invoice
    |> :code.priv_dir()
    |> Path.join("cities.json")
    |> File.read!()
    |> Jason.decode!()
    |> MapSet.new()
  end

  defp filter_by_country(cities, country) do
    cities
    |> MapSet.filter(fn %{"country_name" => country_name} -> country_name == country end)
    |> MapSet.to_list()
    |> Stream.map(&Map.get(&1, "name"))
    |> Enum.to_list
  end
end
