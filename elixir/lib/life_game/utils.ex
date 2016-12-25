defmodule LifeGame.Utils do
  def str_to_grid(width, height, str) do
    allowed_chars = [_dead, alive] = '-#'
    str
    |> String.to_charlist
    |> Stream.filter(fn x -> x in allowed_chars end)  # Filter formatting.
    |> Stream.map(fn x -> x == alive end)  # Convert to boolean.
    |> Stream.zip(0..width*height-1)  # Add coordinates.
    |> Stream.filter(fn {cell, i} -> cell end)
    |> Enum.into(%{}, fn {cell, i} -> {i, cell} end) # Insert into map.
  end
end