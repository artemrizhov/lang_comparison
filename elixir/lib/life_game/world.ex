defmodule LifeGame.World do
  @moduledoc """
  The Game of Life implemented in funcional style in Elixir.
  https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
  """
  @author "Artem Rizhov"

  defstruct [:grid, :width, :height]

  @width 300
  @height 300
  @cell_size 5
  @cell_color {0, 100, 0}
  @bg_color {255, 255, 255}
  @interval 10  # Milliseconds.
  @init_density 0.1  # From 0 to 1.

  alias LifeGame.World, as: World
  alias LifeGame.Screen, as: Screen

  def start_link(name) do
    {:ok, pid} = Task.start_link(&start/0)
    Process.register pid, name
    {:ok, pid}
  end

  def start do
    screen = Screen.init("Game of Life",
                         @width * @cell_size, @height * @cell_size)
    create_random(@width, @height, @init_density) |> run(screen)
  end

  def run(world, screen) do
    Screen.update(screen, @bg_color,
                  &(render &1, world, @cell_size, @cell_color))
    Process.sleep @interval
    world |> next_step |> run(screen)
  end

  def create_random(width, height, init_density) do
    %World{
      width: width, height: height,
      grid: random_grid(width, height, init_density)
    }
  end

  def random_grid(width, height, init_density) do
    coords = grid_coords(width, height)
    coords |> random_cells(init_density) |> grid_from_list
  end

  def random_cells(coords, init_density) do
    Enum.map coords, fn coord ->
      random_cell coord, init_density
    end
  end

  def grid_from_list(list) do
    # Grid is represented as one-dimensional tuple.
    List.to_tuple list
  end

  def random_cell(_coord, probability) do
    :rand.uniform() <= probability
  end

  def next_step(world) do
    %{world | grid: grid_from_list(
      for coord <- grid_coords(world) do
        next_cell_state(world, coord)
      end
    )}
  end

  def next_cell_state(world, coord) do
    # Count populated neighbours.
    neighbours = neighbours(world, coord)
    alive_count = count(neighbours, fn cell -> cell_alive?(world, cell) end)
    # Choice next value.
    if cell_alive?(world, coord) do
      alive_count >= 2 and alive_count <= 3
    else
      alive_count == 3
    end
  end

  @doc """
  More efficient version of Enum.count.
  http://stackoverflow.com/questions/41175829/why-enum-map-is-more-efficient-than-enum-count-in-elixir/41177073#41177073
  https://github.com/elixir-lang/elixir/commit/9d39ebca079350ead3cec55d002937bbb836980a
  TODO: replace with Enum.count when new Elixir version released (current v1.3.4)
  """
  def count(enumerable, fun) when is_function(fun, 1) do
    Enum.reduce(enumerable, 0, fn(entry, acc) ->
      if fun.(entry), do: acc + 1, else: acc
    end)
  end

  def grid_coords(width, height) do
    Stream.unfold {0, 0}, fn
      # End of grid.
      {0, ^height} -> nil;
      # End of line.
      {x, y} when x == width - 1 -> {{x, y}, {0, y + 1}};
      # Limits are not reached.
      {x, y} -> {{x, y}, {x + 1, y}};
    end
  end

  def grid_coords(world), do: grid_coords(world.width, world.height)

  def neighbours(world, {x, y}) do
    x1 = if x == 0, do: world.width - 1, else: x - 1
    y1 = if y == 0, do: world.height - 1, else: y - 1
    y3 = if y == world.height - 1, do: 0, else: y + 1
    x3 = if x == world.width - 1, do: 0, else: x + 1
    x2 = x
    y2 = y
    [{x1, y1}, {x1, y2}, {x1, y3},
     {x2, y1}, {x2, y3},
     {x3, y1}, {x3, y2}, {x3, y3}]
  end

  def cell_alive?(world, {x, y}) do
    elem world.grid, y * world.width + x
  end

  def render(context, world, cell_size, cell_color) do
    for coord = {x, y} <- grid_coords(world), cell_alive?(world, coord) do
      Screen.draw_rectangle(
        context, cell_color,
        {x * cell_size, y * cell_size}, {cell_size, cell_size})
    end
  end
end
