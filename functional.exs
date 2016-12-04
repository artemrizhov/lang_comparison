defmodule LifeGame do
  @moduledoc """
  The Game of Life implemented in funcional style in Elixir.
  https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
  """
  @author "Artem Rizhov"

  @width 300
  @height 300
  @cell_size 5
  @cell_color {0, 100, 0}
  @bg_color {255, 255, 255}
  @interval 10  # Milliseconds.
  @init_density 0.1  # From 0 to 1.

  alias LifeGame.World, as: World

  def start do
    screen = Screen.init("Game of Life",
                         @width * @cell_size, @height * @cell_size)
    World.create_random(@width, @height, @init_density) |> run(screen)
  end

  def run(world, screen) do
    Screen.update(screen, @bg_color,
                  &(World.render &1, world, @cell_size, @cell_color))
    Process.sleep @interval
    world |> World.next_step |> run(screen)
  end
end


defmodule LifeGame.World do
  defstruct [:grid, :width, :height]

  alias LifeGame.World, as: World

  def create_random(width, height, init_density) do
    %World{
      width: width, height: height,
      # The grid is a one-dimensional tuple.
      grid: grid_coords(width, height)
        |> Enum.map(&(random_cell &1, init_density)) |> List.to_tuple
    }
  end

  def random_cell(_coord, probability) do
    :rand.uniform() <= probability
  end

  def next_step(world) do
    %{world | grid:
      grid_coords(world) |> Enum.map(&(next_cell_state(world, &1)))
      |> List.to_tuple }
  end

  def next_cell_state(world, coord) do
    # Count populated neighbours.
    alive_count =
      neighbours(world, coord)
      |> Enum.map(&(if cell_alive?(world, &1), do: 1, else: 0)) |> Enum.sum
    # Choice next value.
    if cell_alive?(world, coord) do
      alive_count >= 2 and alive_count <= 3
    else
      alive_count == 3
    end
  end

  def grid_coords(width, height) do
    Stream.unfold({0, 0}, fn
      # End of grid.
      {0, ^height} -> nil;
      # End of line.
      {x, y} when x == width - 1 -> {{x, y}, {0, y + 1}};
      # Limits are not reached.
      {x, y} -> {{x, y}, {x + 1, y}};
    end)
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
        x * cell_size, y * cell_size, cell_size, cell_size)
    end
  end
end


defmodule Screen do
  @moduledoc """
  Allows to draw simple graphics using wxWidgets.
  """
  @author "Artem Rizhov"

  import Bitwise
  import WxConstants

  def init(title, width, height) when is_binary(title) do
    init to_charlist(title), width, height
  end
  def init(title, width, height) do
    :wx.new()
    frame = :wxFrame.new(
      :wx.null, wxID_ANY, title, size: {width, height},
       style: wxSYSTEM_MENU ||| wxMINIMIZE_BOX  ||| wxCLOSE_BOX ||| wxCAPTION)
    :wxFrame.show frame
    frame
  end

  def update(frame, bg_color, render) do
    # Create drawing context.
    dc = :wxBufferedPaintDC.new(frame)
    # Clear screen.
    :wxDC.setBackground dc, brush = :wxBrush.new(bg_color)
    :wxDC.clear dc
    :wxBrush.destroy brush
    # Call the render function.
    render.(dc)
    # This is required to make the changes visible.
    :wxBufferedPaintDC.destroy dc
  end

  def draw_rectangle(dc, color, x, y, width, height) do
    :wxDC.setPen dc, pen = :wxPen.new(color, [width: 1])
    :wxDC.setBrush dc, brush = :wxBrush.new(color)
    :wxDC.drawRectangle dc, {x, y}, {width, height}
    :wxPen.destroy pen
    :wxBrush.destroy brush
  end
end


LifeGame.start()