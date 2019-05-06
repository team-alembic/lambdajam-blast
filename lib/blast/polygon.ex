defmodule Blast.Polygon do
  @moduledoc """
  A polygon is a list of vertices. The first and last vertex are treated as joined.

  The game engine assumes the polygon ss specified with the "front" pointing upwards and
  in the same coordinate system as the world coordinates. Top-left is 0,0.
  """
  alias Blast.Vector2D

  defstruct [:vertices]

  def new(points) when is_list(points) do
    %__MODULE__{vertices: points |> Enum.map(fn {x, y} -> Vector2D.new(x, y) end)}
  end

  # Returns the centre of the polygon as a Vector2D
  def centre(%__MODULE__{vertices: vertices}) do
    count = length(vertices)

    {totalX, totalY} =
      vertices |> Enum.reduce({0, 0}, fn (%{x: x, y: y}, {sumX, sumY}) ->
        {sumX + x, sumY + y}
      end)

    Vector2D.new(totalX / count, totalY / count)
  end
end