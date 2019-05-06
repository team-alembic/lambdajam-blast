defmodule Blast.Player do
  @moduledoc """
  A player has an id (1 through to 4)

  The first player to join the game has id = 1, the second id = 2 and so on.

  The id is used to determine the initial positions.

  `position` is a unit Vector2D
  """
  defstruct [
    # Player ID
    :id,
    # Position of the player
    :position,
    # Orientation of the player (offset from north).
    # This is the direction in which thrust will be applied.
    :orientation,
    # Direction of motion of the player (offset from north)
    :motion,
    # Whether the platyer is turning (:left, :right, :not_turning)
    :turning,
    # Whether the thruster is on or off (:on, :off)
    :thrusters
  ]

  import Blast.Vector2D

  @vertices [new(25, 0), new(40, 50), new(25, 40), new(10, 50)]

  def vertices, do: @vertices

  # TODO move this to a generic Polygon module (and define vertices using the Polygon module)
  def centre do
    {totalX, totalY} =
      vertices() |> Enum.reduce({0, 0}, fn (%{x: x, y: y}, {sumX, sumY}) ->
        {sumX + x, sumY + y}
      end)

    new(totalX / length(vertices()), totalY / length(vertices()))
  end

  def set_turning(player = %__MODULE__{}, option) when option in [:right, :left, :not_turning] do
    %__MODULE__{player | turning: option}
  end

  def set_thrusters(player = %__MODULE__{}, on_or_off) when on_or_off in [:on, :off] do
    %__MODULE__{player | thrusters: on_or_off}
  end
end