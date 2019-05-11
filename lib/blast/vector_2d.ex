defmodule Blast.Vector2D do
  @moduledoc """
  Module for representing and performing operations on 2D mathematical vectors.
  """
  use TypedStruct

  alias Blast.Vector2D

  typedstruct enforce: true do
    field :x, float()
    field :y, float()
  end

  @degrees_per_radian 57.2958

  def north, do: unit(new(0, -1))
  def east, do: unit(new(1, 0))
  def south, do: unit(new(1, 1))
  def west, do: unit(new(-1, 0))

  def new(x, y) do
    %Vector2D{x: x, y: y}
  end

  @doc """
  Return the magnitude (length) of the vector.
  """
  def mag(%Vector2D{x: x, y: y}) do
    :math.sqrt(x * x + y * y)
  end

  @doc """
  Return a vector of unit length with direction preserved.
  """
  def unit(v = %Vector2D{x: x, y: y}) do
    len = mag(v)

    if len > 0 do
      %Vector2D{x: x / len, y: y / len}
    else
      v
    end
  end

  @doc """
  Add two vectors together.
  """
  def add(%Vector2D{x: x1, y: y1}, %Vector2D{x: x2, y: y2}) do
    %Vector2D{x: x1 + x2, y: y1 + y2}
  end

  @doc """
  Subtract one vector from another.
  """
  def sub(%Vector2D{x: x1, y: y1}, %Vector2D{x: x2, y: y2}) do
    %Vector2D{x: x1 - x2, y: y1 - y2}
  end

  @doc """
  Multiply the magnitude of the vector by a multiplier.
  """
  def multiply_mag(%Vector2D{x: x, y: y}, multiplier) do
    %Vector2D{x: x * multiplier, y: y * multiplier}
  end

  @doc """
  Computes the dot product of two Vector2D
  """
  def dot(%Vector2D{x: x1, y: y1}, %Vector2D{x: x2, y: y2}) do
    x1 * x2 + y1 * y2
  end

  @doc """
  Computes the cross product of two Vector2D
  """
  def cross(%Vector2D{x: x1, y: y1}, %Vector2D{x: x2, y: y2}) do
    x1 * y2 - x2 * y1
  end

  @doc """
  Computes the signed angle in degrees between two vectors in degrees (not radians).

  Output is -180 to +180.
  """
  def signed_angle_between(v1 = %Vector2D{}, v2 = %Vector2D{}) do
    :math.atan2(cross(v1, v2), dot(v1, v2)) * @degrees_per_radian
  end

  @doc """
  Negate the `x` component of the vector.
  """
  def invert_x(%Vector2D{x: x, y: y}) do
    %Vector2D{x: -x, y: y}
  end

  @doc """
  Negate the `y` component of the vector.
  """
  def invert_y(%Vector2D{x: x, y: y}) do
    %Vector2D{x: x, y: -y}
  end

  @doc """
  Rotates a vector about the origin (0, 0).

  +ve degrees are right, -ve are left
  """
  def rotate(%Vector2D{x: x, y: y}, degrees) do
    radians = degrees * (:math.pi() / 180)

    %Vector2D{
      x: x * :math.cos(radians) - y * :math.sin(radians),
      y: x * :math.sin(radians) + y * :math.cos(radians)
    }
  end

  @doc """
  Return the distance between two vectors using Pythagoras Theorem.
  """
  def distance_between(%Vector2D{x: x1, y: y1}, %Vector2D{x: x2, y: y2}) do
    :math.sqrt(
      :math.pow(abs(x1 - x2), 2) +
        :math.pow(abs(y1 - y2), 2)
    )
  end
end
