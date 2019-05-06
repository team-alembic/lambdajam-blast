defmodule Blast.Projectile do
  @moduledoc """
  Represents a projectile fired by a player weapon.
  """
  defstruct [
    :position,
    :velocity,
    :orientation,
    :polygon,
    :rebounds_remaining
  ]


  alias Blast.Vector2D
  alias Blast.Polygon

  @polygon Polygon.new([{25 / 5, 0}, {40 / 5, 50 / 5}, {25 / 5, 40/ 5}, {10/ 5, 50 / 5}])

  def new(position, velocity, orientation) do
    %__MODULE__{
      position: position,
      velocity: velocity,
      orientation: orientation,
      polygon: @polygon,
      rebounds_remaining: 3
    }
  end

  def apply_velocity(projectile = %__MODULE__{
    position: position,
    velocity: velocity
  }) do
    %__MODULE__{projectile | position: Vector2D.add(position, velocity)}
  end
end