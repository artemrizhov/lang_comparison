defmodule LifeGame.Utils do
  def str_to_grid(str) when is_binary(str) do
    allowed_chars = [_dead, alive] = '-#'
    str
    |> String.to_charlist
    |> Stream.filter(fn x -> x in allowed_chars end) # Filter formatting.
    |> Enum.map(fn x -> x == alive end)  # Convert to boolean.
    |> List.to_tuple
  end
end