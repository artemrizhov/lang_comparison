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

  alias LifeGame.World
  alias LifeGame.Screen


  # This macros is defined to improve the code performace.
  defmacro is_alive(cell), do: quote do: unquote(cell)


  def start_link(name) do
    {:ok, pid} = Task.start_link(&start/0)
    Process.register pid, name
    {:ok, pid}
  end

  def start do
    screen = Screen.init("Game of Life", @width * @cell_size, @height * @cell_size)
    world = create_random(@width, @height, @init_density)
    run world, screen
  end

  def run(world, screen) do
    Screen.update screen, @bg_color, &(render &1, world, @cell_size, @cell_color)
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
    for coord <- coords, into: %{} do
      {coord, random_cell(coord, init_density)}
    end
  end

  def random_cell(_coord, probability) do
    :rand.uniform() <= probability
  end

  @doc """
  Returns the world at the next step.
  """
  def next_step(world) do
    %{world | grid: next_grid_state(world)}
  end

  def next_grid_state(world) do
    for {coord, cell} <- world.grid, into: %{} do
      neighbours = neighbours(world, coord)
      {coord, next_cell_state(cell, neighbours)}
    end
  end

  @doc """
  Get the cell state for the next step of the world time.
  """
  def next_cell_state(cell, neighbours) do
    # Enum.count is not used for speed optimisation.
    # TODO: Try lover API.
    alive_count = Enum.reduce(neighbours, 0, fn(cell, count) ->
      if is_alive(cell), do: count + 1, else: count
    end)
    # Choice next value.
    if is_alive(cell) do
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
    Enum.reduce enumerable, 0, fn(entry, acc) ->
      if fun.(entry), do: acc + 1, else: acc
    end
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

  @doc """
  Get the neighbour cells.
  This function is optimized for speed.
  """
  def neighbours(%{grid: grid, width: width, height: height}, {x, y}) do
    x1 = if x == 0, do: width - 1, else: x - 1
    y1 = if y == 0, do: height - 1, else: y - 1
    y3 = if y == height - 1, do: 0, else: y + 1
    x3 = if x == width - 1, do: 0, else: x + 1
    x2 = x
    y2 = y
    [grid[{x1, y1}], grid[{x1, y2}], grid[{x1, y3}],
     grid[{x2, y1}], grid[{x2, y3}],
     grid[{x3, y1}], grid[{x3, y2}], grid[{x3, y3}]]
  end

  def render(context, world, cell_size, cell_color) do
    for {{x, y}, cell} <- world.grid, is_alive(cell) do
      Screen.draw_rectangle(
        context, cell_color,
        {x * cell_size, y * cell_size}, {cell_size, cell_size})
    end
  end
end
