defmodule Blast.Player do
  @moduledoc """
  A player has an id (1 through to 4)

  The first player to join the game has id = 1, the second id = 2 and so on.

  The id is used to determine the initial positions.

  `position` is a unit Vector2D
  """
  defstruct [:id, :position, :orientation, :turning, :thrusting]

  import Blast.Vector2D

  def vertices, do: [new(25, 0), new(40, 50), new(25, 40), new(10, 50)]

  def centre do
    {totalX, totalY} =
      vertices() |> Enum.reduce({0, 0}, fn (%{x: x, y: y}, {sumX, sumY}) ->
        {sumX + x, sumY + y}
      end)

    new(totalX / length(vertices()), totalY / length(vertices()))
  end

  def set_turning(player = %__MODULE__{}, direction) when direction in [:clockwise, :anticlockwise, :paused] do
    %__MODULE__{player | turning: direction}
  end

  def set_thrusting(player = %__MODULE__{}, enabled) when is_boolean(enabled) do
    %__MODULE__{player | thrusting: enabled}
  end
end