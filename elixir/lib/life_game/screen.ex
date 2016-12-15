defmodule LifeGame.Screen do
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

  def draw_rectangle(dc, color, {x, y}, {width, height}) do
    :wxDC.setPen dc, pen = :wxPen.new(color, [width: 1])
    :wxDC.setBrush dc, brush = :wxBrush.new(color)
    :wxDC.drawRectangle dc, {x, y}, {width, height}
    :wxPen.destroy pen
    :wxBrush.destroy brush
  end
end
