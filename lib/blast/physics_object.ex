defmodule Blast.PhysicsObject do
  @moduledoc """
  This represents an object with mass, velicity etc that forces can be applied to.
  """

  alias Blast.Vector2D
  alias Blast.Polygon
  alias Blast.PhysicsObject

  use TypedStruct

  typedstruct enforce: true do
    field :position, Vector2D.t()
    field :orientation, Vector2D.t()
    field :velocity, Vector2D.t(), default: Vector2D.new(0, 0)
    field :mass, pos_integer()
    field :polygon, Polygon.t()
    field :rebounds_remaining, pos_integer() | :unlimited, default: :unlimited
    field :rebound_velocity_adjustment, float(), default: 0.75
    field :max_allowed_speed, float()
  end

  def new(values = %{}) do
    struct(PhysicsObject, values)
  end

  @doc """
  Rotate a object with angular velocity of 1.5 seconds for full rotation.
  """
  def rotate(object = %PhysicsObject{orientation: orientation}, :left, frame_millis) do
    %PhysicsObject{object | orientation: Vector2D.rotate(orientation, -(frame_millis / 1500.0) * 360)}
  end
  def rotate(object = %PhysicsObject{orientation: orientation}, :right, frame_millis) do
    %PhysicsObject{object | orientation: Vector2D.rotate(orientation, (frame_millis / 1500.0) * 360)}
  end

  @doc """
  Accelerate object in direction of orientation for `time_delta_millis`.

  Uses Newtonian mechanics to calculate an updated velocity for an acceleration over `time_delta_millis`.
  """
  def apply_thrust(object, force_newtons, time_delta_millis)
  def apply_thrust(object = %PhysicsObject{
    velocity: velocity,
    mass: mass,
    orientation: orientation,
    max_allowed_speed: max_allowed_speed
  },
    force_newtons,
    time_delta_millis
  ) do
    if max_allowed_speed == :unlimited || abs(Vector2D.mag(velocity)) < max_allowed_speed do
      force_vector = Vector2D.multiply_mag(orientation, force_newtons)
      new_velocity = apply_force(velocity, mass, force_vector, time_delta_millis)
      %PhysicsObject{object | velocity: new_velocity}
    else
      object
    end
  end
  def apply_thrust(object = %PhysicsObject{}, _), do: object


  # Calculate new velocity when force is applied to an object for a period of time.
  defp apply_force(
    velocity = %Vector2D{},
    mass_kg,
    force_newtons = %Vector2D{},
    time_delta_millis
  ) do
    acceleration = Vector2D.mag(force_newtons) / mass_kg
    velocity_contribution =
      Vector2D.multiply_mag(force_newtons, (time_delta_millis / 1000) * acceleration)
    Vector2D.add(velocity, velocity_contribution)
  end

  def apply_velocity(object = %PhysicsObject{
    position: position,
    velocity: velocity
  }) do
    %PhysicsObject{object | position: Vector2D.add(position, velocity)}
  end

  @doc """
  Prevents an object from leaving the bounds of the arena.

  Position is capped at between 0 -> `arena_size` in the x and y dimensions and
  velocity is inverted along the axis of a collision.

  # Fun exercise: option to allow a wrapping world?

  #TODO: do proper collision detection with object's polygon instead of simply the position.
  """
  def apply_edge_collisions(object, arena_size)
  def apply_edge_collisions(object = %PhysicsObject{position: %Vector2D{x: x}}, arena_size) when x > arena_size do
    apply_edge_collisions(%PhysicsObject{object |
      velocity: object.velocity |> Vector2D.invert_x() |> Vector2D.multiply_mag(object.rebound_velocity_adjustment),
      position: %Vector2D{object.position | x: arena_size},
    }, arena_size)
  end
  def apply_edge_collisions(object = %PhysicsObject{position: %Vector2D{x: x}}, arena_size) when x < 0 do
    apply_edge_collisions(%PhysicsObject{object |
      velocity: object.velocity |> Vector2D.invert_x() |> Vector2D.multiply_mag(object.rebound_velocity_adjustment),
      position: %Vector2D{object.position | x: 0},
    }, arena_size)
  end
  def apply_edge_collisions(object = %PhysicsObject{position: %Vector2D{y: y}}, arena_size) when y > arena_size do
    apply_edge_collisions(%PhysicsObject{object |
      velocity: object.velocity |> Vector2D.invert_y() |> Vector2D.multiply_mag(object.rebound_velocity_adjustment),
      position: %Vector2D{object.position | y: arena_size},
    }, arena_size)
  end
  def apply_edge_collisions(object = %PhysicsObject{position: %Vector2D{y: y}}, arena_size) when y < 0 do
    apply_edge_collisions(%PhysicsObject{object |
      velocity: object.velocity |> Vector2D.invert_y() |> Vector2D.multiply_mag(object.rebound_velocity_adjustment),
      position: %Vector2D{object.position | y: 0},
    }, arena_size)
  end
  def apply_edge_collisions(object = %PhysicsObject{}, _), do: object
end
