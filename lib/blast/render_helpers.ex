defmodule Blast.RenderHelpers do
  @moduledoc """
  Helper functions for rendering Polygons as SVG.
  """
  alias Blast.Polygon

  use Phoenix.HTML

  def render_polygon(%Polygon{vertices: vertices}) do
    raw(
      Enum.map(vertices, fn %{x: x, y: y} ->
        "#{round(x)} #{round(y)}"
      end)
      |> Enum.join(", ")
    )
  end

  def polygon_centre(polygon = %Polygon{}) do
    %{x: x, y: y} = Polygon.centre(polygon)
    raw("#{round(x)} #{round(y)}")
  end

  def polygon_centre_x(polygon = %Polygon{}) do
    %{x: x} = Polygon.centre(polygon)
    round(x)
  end

  def polygon_centre_y(polygon = %Polygon{}) do
    %{y: y} = Polygon.centre(polygon)
    round(y)
  end
end
