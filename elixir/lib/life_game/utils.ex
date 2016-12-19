defmodule LifeGame.Utils do
  alias LifeGame.World

  def str_to_grid(width, height, str) do
    allowed_chars = [_dead, alive] = '-#'
    str
    |> String.to_charlist
    |> Stream.filter(fn x -> x in allowed_chars end)  # Filter formatting.
    |> Enum.map(fn x -> x == alive end)  # Convert to boolean.
    |> Stream.zip(World.grid_coords(width, height))  # Add coordinates.
    |> Enum.into(%{}, fn {cell, coord} -> {coord, cell} end) # Insert into map.
  end
end