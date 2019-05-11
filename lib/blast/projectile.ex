defmodule Blast.Projectile do
  @moduledoc """
  Contains function to create a new PhysicsObject representing a projectile fired by a weapon.
  """

  alias Blast.Polygon
  alias Blast.PhysicsObject
  alias Blast.Vector2D
  alias Blast.Fighter
  alias Blast.Projectile

  @polygon Polygon.new([{25 / 5, 0}, {40 / 5, 50 / 5}, {25 / 5, 40 / 5}, {10 / 5, 50 / 5}])

  def polygon, do: @polygon

  use TypedStruct

  typedstruct enforce: true do
    field :fired_by_fighter_id, pos_integer()
    field :object, PhysicsObject.t()
  end

  @doc """
  Creates a new Projectile as if fired by a Fighter.

  The projectile emanates from the front (north) of `fired_by.object.polygon`.
  """
  def fired_by(fighter = %Fighter{}) do
    %PhysicsObject{
      position: base_position,
      polygon: polygon,
      velocity: velocity,
      orientation: firing_direction
    } = fighter.object

    %Projectile{
      fired_by_fighter_id: fighter.id,
      object: %PhysicsObject{
        :position => calc_position(base_position, calc_offset(polygon), firing_direction),
        :orientation => firing_direction,
        :velocity => calc_velocity(velocity, firing_direction),
        :mass => 5,
        :polygon => @polygon,
        :rebounds_remaining => 1,
        :rebound_velocity_adjustment => 1.0,
        :max_allowed_speed => 1000
      }
    }
  end

  def update(p = %Projectile{}, values = %{}) do
    struct(p, values)
  end

  defp calc_position(base_position, offset, firing_direction) do
    Vector2D.add(
      Vector2D.add(
        base_position,
        Vector2D.rotate(
          offset,
          Vector2D.signed_angle_between(offset, firing_direction)
        )
      ),
      Vector2D.multiply_mag(Vector2D.unit_random(), 3)
    )
  end

  defp calc_offset(polygon) do
    Vector2D.sub(
      Polygon.centre_top(polygon),
      Vector2D.new(0, Polygon.top_y(polygon) / 2)
    )
  end

  defp calc_velocity(velocity, firing_direction) do
    Vector2D.add(
      velocity,
      Vector2D.add(
        firing_direction,
        Vector2D.add(
          Vector2D.multiply_mag(Vector2D.unit(firing_direction), 10),
          Vector2D.multiply_mag(Vector2D.unit_random(), 0.5)
        )
      )
    )
  end
end
