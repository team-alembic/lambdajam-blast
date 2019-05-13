defmodule Blast.LowPrecisionVector2D do
  @moduledoc """
  Module for representing a lower fidelity vector.
  """
  use TypedStruct

  alias Blast.LowPrecisionVector2D
  alias Blast.Vector2D

  typedstruct enforce: true do
    field(:x, float())
    field(:y, float())
    field(:vector_2d, Vector2D.t())
  end

  @reduced_precision_decimal_places 2

  def add(%LowPrecisionVector2D{x: _, y: _, vector_2d: vector_2d_1}, %LowPrecisionVector2D{
        x: _,
        y: _,
        vector_2d: vector_2d_2
      }) do
    new(Vector2D.add(vector_2d_1, vector_2d_2))
  end

  def add([]), do: raise("expected a non-empty list")
  def add([v = %LowPrecisionVector2D{}]), do: v

  def add([v1 = %LowPrecisionVector2D{} | [v2 = %LowPrecisionVector2D{} | rest]]) do
    add([add(v1, v2) | rest])
  end

  def distance_between(
        %LowPrecisionVector2D{x: _, y: _, vector_2d: vector_2d_1},
        %LowPrecisionVector2D{x: _, y: _, vector_2d: vector_2d_2}
      ) do
    Vector2D.distance_between(vector_2d_1, vector_2d_2)
  end

  def dot(%LowPrecisionVector2D{x: _, y: _, vector_2d: vector_2d_1}, %LowPrecisionVector2D{
        x: _,
        y: _,
        vector_2d: vector_2d_2
      }) do
    Vector2D.dot(vector_2d_1, vector_2d_2)
  end

  def invert_x(%LowPrecisionVector2D{x: _, y: _, vector_2d: vector_2d}) do
    new(Vector2D.invert_x(vector_2d))
  end

  def invert_y(%LowPrecisionVector2D{x: _, y: _, vector_2d: vector_2d}) do
    new(Vector2D.invert_y(vector_2d))
  end

  def mag(%LowPrecisionVector2D{x: _, y: _, vector_2d: vector_2d}) do
    Vector2D.mag(vector_2d)
  end

  def multiply_mag(%LowPrecisionVector2D{x: _, y: _, vector_2d: vector_2d}, multiplier) do
    new(Vector2D.multiply_mag(vector_2d, multiplier))
  end

  def new(vector_2d = %Vector2D{}) do
    %LowPrecisionVector2D{
      x: reduced_precision(vector_2d.x),
      y: reduced_precision(vector_2d.y),
      vector_2d: vector_2d
    }
  end

  def new(x, y) do
    new(Vector2D.new(x, y))
  end

  def rotate(%LowPrecisionVector2D{x: _, y: _, vector_2d: vector_2d}, degrees) do
    new(Vector2D.rotate(vector_2d, degrees))
  end

  def signed_angle_between(
        %LowPrecisionVector2D{x: _, y: _, vector_2d: vector_2d_1},
        %LowPrecisionVector2D{x: _, y: _, vector_2d: vector_2d_2}
      ) do
    reduced_precision(Vector2D.signed_angle_between(vector_2d_1, vector_2d_2))
  end

  def sub(
        %LowPrecisionVector2D{x: _, y: _, vector_2d: vector_2d_1},
        %LowPrecisionVector2D{x: _, y: _, vector_2d: vector_2d_2}
      ) do
    new(Vector2D.sub(vector_2d_1, vector_2d_2))
  end

  def sub([]), do: raise("expected a non-empty list")
  def sub([v = %LowPrecisionVector2D{}]), do: v

  def sub([v1 = %LowPrecisionVector2D{} | [v2 = %LowPrecisionVector2D{} | rest]]) do
    sub([sub(v1, v2) | rest])
  end

  def unit(%LowPrecisionVector2D{x: _, y: _, vector_2d: vector_2d}) do
    new(Vector2D.unit(vector_2d))
  end

  def unit_random() do
    new(Vector2D.unit_random())
  end

  defp reduced_precision(number) do
    case is_integer(number) do
      true -> number
      false -> Float.round(number, @reduced_precision_decimal_places)
    end
  end
end
