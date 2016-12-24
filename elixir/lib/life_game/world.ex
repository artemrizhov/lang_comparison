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
  @interval 0  # Milliseconds.
  @init_density 0.1  # From 0 to 1.

  alias LifeGame.World
  alias LifeGame.Screen

  defmacro to_coord(i, width) do
    quote do
      {rem(unquote(i), unquote(width)), div(unquote(i), unquote(width))}
    end
  end
  defmacro cell(world, {x, y}) do
    quote do
      unquote(world).grid[unquote(y) * unquote(world).width + unquote(x)]
    end
  end
  defmacro cell(grid, width, {x, y}) do
    quote do
      unquote(grid)[unquote(y) * unquote(width) + unquote(x)]
    end
  end
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
    for i <- 0..(width*height-1), into: %{} do
      {i, random_cell(init_density)}
    end
  end

  def random_cell(probability) do
    :rand.uniform() <= probability
  end

  @doc """
  Returns the world at the next step.
  """
  def next_step(world) do
    %{world | grid: next_grid_state(world)}
  end

  def next_grid_state(world) do
    Enum.into(for {i, cell} <- world.grid do
      coord = to_coord(i, world.width)
      neighbours = neighbours(world, coord)
      {i, next_cell_state(cell, neighbours)}
    end, %{})
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
    [cell(grid, width, {x1, y1}), cell(grid, width, {x1, y2}),
     cell(grid, width, {x1, y3}),
     cell(grid, width, {x2, y1}), cell(grid, width, {x2, y3}),
     cell(grid, width, {x3, y1}), cell(grid, width, {x3, y2}),
     cell(grid, width, {x3, y3})]
  end

  def render(context, world, cell_size, cell_color) do
    for {i, cell} <- world.grid, is_alive(cell) do
      {x, y} = to_coord(i, world.width)
      Screen.draw_rectangle(
        context, cell_color,
        {x * cell_size, y * cell_size}, {cell_size, cell_size})
    end
  end
end
