defmodule Blast.Vector2D do
  @moduledoc """
  Module for representing and performing operations on 2D mathematical vectors.
  """
  defstruct [:x, :y]

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
end