defmodule Blast.Polygon do
  @moduledoc """
  A polygon is a list of vertices. The first and last vertex are treated as joined.

  The game engine assumes the polygon is specified with the "front" pointing upwards and
  in the same coordinate system as the world coordinates. Top-left is 0,0.
  """
  alias Blast.Vector2D
  alias Blast.Polygon

  use TypedStruct

  typedstruct enforce: true do
    field(:vertices, list(Vector2D.t()))
  end

  def new(points) when is_list(points) do
    %Polygon{vertices: points |> Enum.map(fn {x, y} -> Vector2D.new(x, y) end)}
  end

  # Returns the centre of the polygon as a Vector2D
  def centre(%Polygon{vertices: vertices}) do
    count = length(vertices)

    {totalX, totalY} =
      vertices
      |> Enum.reduce({0, 0}, fn %{x: x, y: y}, {sumX, sumY} ->
        {sumX + x, sumY + y}
      end)

    Vector2D.new(totalX / count, totalY / count)
  end

  @doc """
  Returns the `y` coordinate of the top-most vertex.
  """
  def top_y(%Polygon{vertices: vertices}) do
    vertices
    |> Enum.map(fn %{y: y} -> y end)
    |> Enum.reduce(0, &max(&1, &2))
  end

  @doc """
  Gets the centre-top vertex
  """
  def centre_top(polygon = %Polygon{}) do
    %{x: x} = centre(polygon)
    Vector2D.new(x, top_y(polygon))
  end

  @doc """
  Returns the radius of an imaginary sphere centred on the centre of the polygon.
  """
  def bounding_sphere_radius(polygon = %Polygon{vertices: vertices}) do
    c = centre(polygon)
    biggest_v = Enum.max_by(vertices, fn v -> Vector2D.distance_between(v, c) end)
    Vector2D.distance_between(biggest_v, c)
  end
end
