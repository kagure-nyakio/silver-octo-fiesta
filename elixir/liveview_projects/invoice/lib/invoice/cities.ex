defmodule Invoice.Cities do
  @moduledoc """
  Returns information about cities and cities
  """
  use Agent

  def start_link(_) do
    Agent.start_link(&cities/0, name: __MODULE__)
  end

  def get_cities_by_country(country) do
    Agent.get(__MODULE__, &filter_by_country(&1, country))
  end

  def get_countries do
    Agent.get(__MODULE__, &fetch_countries/1)
  end

  defp cities do
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

  defp fetch_countries(cities) do
    cities
    |> Enum.map(&Map.get(&1, "country_name"))
  end
end
