defmodule Blast.Vector2D do
  @moduledoc """
  Module for representing and performing operations on 2D mathematical vectors.
  """
  use TypedStruct

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
    %__MODULE__{x: x, y: y}
  end

  @doc """
  Return the magnitude (length) of the vector.
  """
  def mag(%__MODULE__{x: x, y: y}) do
    :math.sqrt(x * x + y * y)
  end

  @doc """
  Return a vector of unit length with direction preserved.
  """
  def unit(v = %__MODULE__{x: x, y: y}) do
    len = mag(v)
    if len > 0 do
      %__MODULE__{x: x / len, y: y / len}
    else
      v
    end
  end

  # TODO: add test
  def add(%__MODULE__{x: x1, y: y1}, %__MODULE__{x: x2, y: y2}) do
    %__MODULE__{x: x1 + x2, y: y1 + y2}
  end

  # TODO: add test
  def sub(%__MODULE__{x: x1, y: y1}, %__MODULE__{x: x2, y: y2}) do
    %__MODULE__{x: x1 - x2, y: y1 - y2}
  end

  def multiply_mag(%__MODULE__{x: x, y: y}, multiplier) do
    %__MODULE__{x: x * multiplier, y: y * multiplier}
  end

  @doc """
  Computes the dot product of two Vector2D
  """
  def dot(%__MODULE__{x: x1, y: y1}, %__MODULE__{x: x2, y: y2}) do
    x1 * x2 + y1 * y2
  end

  @doc """
  Computes the cross product of two Vector2D
  """
  def cross(%__MODULE__{x: x1, y: y1}, %__MODULE__{x: x2, y: y2}) do
    x1 * y2 - x2 * y1
  end

  @doc """
  Computes the signed angle in degrees between two vectors in degrees (not radians).

  Output is -180 to +180.
  """
  def signed_angle_between(v1 = %__MODULE__{}, v2 = %__MODULE__{}) do
    :math.atan2(cross(v1, v2), dot(v1, v2)) * @degrees_per_radian
  end

  def invert_x(%__MODULE__{x: x, y: y}) do
    %__MODULE__{x: -x, y: y}
  end

  def invert_y(%__MODULE__{x: x, y: y}) do
    %__MODULE__{x: x, y: -y}
  end

  @doc """
  Rotates a vector about the origin (0, 0).

  +ve degrees are right, -ve are left
  """
  def rotate(%__MODULE__{x: x, y: y}, degrees) do
    radians = degrees * (:math.pi / 180)
    %__MODULE__{
      x: x * :math.cos(radians) - y * :math.sin(radians),
      y: x * :math.sin(radians) + y * :math.cos(radians)
    }
  end
end