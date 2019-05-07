defmodule Blast.Projectile do
  @moduledoc """
  Contains function to create a new PhysicsObject representing a projectile fired by a weapon.
  """

  alias Blast.Polygon
  alias Blast.PhysicsObject
  alias Blast.Vector2D

  @polygon Polygon.new([{25 / 5, 0}, {40 / 5, 50 / 5}, {25 / 5, 40/ 5}, {10/ 5, 50 / 5}])

  @doc """
  Creates a new PhysicObject as if fired by another PhysicsObject.

  The projectile eminates from the top of the object's polygon.
  """
  def fired_by_object(%PhysicsObject{position: position, velocity: velocity, orientation: firing_direction}) do
    %PhysicsObject{
      :position => position,
      :orientation =>  firing_direction,
      :velocity => Vector2D.add(firing_direction, Vector2D.multiply_mag(Vector2D.unit(firing_direction), 10)),
      :mass => 5,
      :polygon => @polygon,
      :rebounds_remaining => 3,
      :rebound_velocity_adjustment => 1.0,
      :max_allowed_speed => 1000
    }
  end
end