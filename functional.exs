require Process
import WxConstants


defmodule LifeGame do
  @width 300
  @height 300
  @cell_size 5
  @bg_color {255, 255, 255}
  @cell_color {0, 100, 0}
  @interval 10  # Milliseconds.
  @init_density 0.1  # From 0 to 1.

  def start do
    screen = Screen.init("Game of Life", @width, @height, @cell_size)
    create_random_grid(@width, @height) |> run(@width, @height, screen)
  end

  def run(grid, width, height, screen) do
    Screen.update screen, &(render &1, grid, width, height)
    Process.sleep @interval
    grid |> make_step(width, height) |> run(width, height, screen)
  end

  def create_random_grid(width, height) do
    List.to_tuple(for _ <- 0..(height-1) do
      List.to_tuple(for _ <- 0..(width-1) do
        :rand.uniform() <= @init_density
      end)
    end)
  end

  def make_step(grid, width, height) do
    List.to_tuple(for y <- 0..(height-1) do
      List.to_tuple(for x <- 0..(width-1) do
        calc_cell(grid, x, y, width, height)
      end)
    end)
  end

  def calc_cell(grid, x, y, width, height) do
    # Count populated neighbours.
    alive_count = Enum.sum(for {nx, ny} <- get_neighbours(x, y, width, height) do
      if grid_elem(grid, nx, ny), do: 1, else: 0
    end)
    if grid_elem(grid, x, y) do
      alive_count >= 2 and alive_count <= 3
    else
      alive_count == 3
    end

  end

  def get_neighbours(x, y, width, height) do
    # Calculates and returns the neighbours coordinates.
    x1 = if x == 0, do: width - 1, else: x - 1
    y1 = if y == 0, do: height - 1, else: y - 1
    y3 = if y == height - 1, do: 0, else: y + 1
    x3 = if x == width - 1, do: 0, else: x + 1
    x2 = x
    y2 = y
    [{x1, y1}, {x1, y2}, {x1, y3},
     {x2, y1}, {x2, y3},
     {x3, y1}, {x3, y2}, {x3, y3}]
  end

  def grid_elem(grid, x, y) do
    elem(elem(grid, y), x)
  end

  def render(dc, grid, width, height) do
    for y <- 0..(height-1) do
      for x <- 0..(width-1) do
        if grid_elem(grid, x, y) do
          Screen.draw_rectangle(
            dc, @cell_color,
            x * @cell_size, y * @cell_size, @cell_size, @cell_size)
        end
      end
    end
  end
end


defmodule Screen do
  import Bitwise

  def init(title, width, height, cell_size) do
    title = to_charlist(title)
    _create_window(title, width * cell_size, height * cell_size)
  end

  def update(frame, renderer) do
    dc = :wxBufferedPaintDC.new(frame)
    # Clear screen.
    :wxDC.setBackground dc, brush = :wxBrush.new({255, 255, 255})
    :wxDC.clear dc
    :wxBrush.destroy brush
    # Call the render function.
    renderer.(dc)
    :wxBufferedPaintDC.destroy dc
  end

  def draw_rectangle(dc, color, x, y, width, height) do
    :wxDC.setPen dc, pen = :wxPen.new(color, [width: 1])
    :wxDC.setBrush dc, brush = :wxBrush.new(color)
    :wxDC.drawRectangle dc, {x, y}, {width, height}
    :wxPen.destroy pen
    :wxBrush.destroy brush
  end

  def _create_window(title, width, height) do
    :wx.new()
    frame = :wxFrame.new(
      :wx.null, wxID_ANY, title, size: {width, height},
       style: wxSYSTEM_MENU ||| wxMINIMIZE_BOX  ||| wxCLOSE_BOX ||| wxCAPTION)
    :wxFrame.show frame
    frame
  end
end


LifeGame.start()