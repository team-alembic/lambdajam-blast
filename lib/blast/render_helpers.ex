defmodule Blast.RenderHelpers do
  alias Blast.Polygon

  use Phoenix.HTML

  def render_polygon(%Polygon{vertices: vertices}) do
    raw(vertices |> Enum.map(fn %{x: x, y: y} -> "#{x} #{y}" end) |> Enum.join(", "))
  end

  def polygon_centre(polygon = %Polygon{}) do
    %{x: x, y: y} = Polygon.centre(polygon)
    raw("#{x} #{y}")
  end

  def polygon_centre_x(polygon = %Polygon{}) do
    %{x: x} = Polygon.centre(polygon)
    x
  end

  def polygon_centre_y(polygon = %Polygon{}) do
    %{y: y} = Polygon.centre(polygon)
    y
  end
end
