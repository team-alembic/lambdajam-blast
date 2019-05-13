defmodule Blast.PhysicsObject do
  @moduledoc """
  This represents an object with mass, velocity etc that forces can be applied to.
  """

  alias Blast.LowPrecisionVector2D
  alias Blast.Polygon
  alias Blast.PhysicsObject

  use TypedStruct

  typedstruct enforce: true do
    field(:position, LowPrecisionVector2D.t())
    field(:orientation, LowPrecisionVector2D.t())
    field(:velocity, LowPrecisionVector2D.t(), default: LowPrecisionVector2D.new(0, 0))
    field(:mass, pos_integer())
    field(:polygon, Polygon.t())
    field(:rebounds_remaining, pos_integer() | :unlimited, default: :unlimited)
    field(:rebound_velocity_adjustment, float(), default: 0.75)
    field(:max_allowed_speed, float())
  end

  def new(values = %{}) do
    struct(PhysicsObject, values)
  end

  @doc """
  Rotate a object with angular velocity of 1.5 seconds for full rotation.
  """
  def rotate(object = %PhysicsObject{orientation: orientation}, :left, frame_millis) do
    %PhysicsObject{
      object
      | orientation: LowPrecisionVector2D.rotate(orientation, -(frame_millis / 1500.0) * 360)
    }
  end

  def rotate(object = %PhysicsObject{orientation: orientation}, :right, frame_millis) do
    %PhysicsObject{
      object
      | orientation: LowPrecisionVector2D.rotate(orientation, frame_millis / 1500.0 * 360)
    }
  end

  @doc """
  Accelerate object in direction of orientation for `time_delta_millis`.

  Uses Newtonian mechanics to calculate an updated velocity for an acceleration over `time_delta_millis`.
  """
  def apply_thrust(object, force_newtons, time_delta_millis)

  def apply_thrust(
        object = %PhysicsObject{
          velocity: velocity,
          mass: mass,
          orientation: orientation,
          max_allowed_speed: max_allowed_speed
        },
        force_newtons,
        time_delta_millis
      ) do
    if max_allowed_speed == :unlimited ||
         abs(LowPrecisionVector2D.mag(velocity)) < max_allowed_speed do
      force_vector = LowPrecisionVector2D.multiply_mag(orientation, force_newtons)
      new_velocity = apply_force(velocity, mass, force_vector, time_delta_millis)
      %PhysicsObject{object | velocity: new_velocity}
    else
      object
    end
  end

  def apply_thrust(object = %PhysicsObject{}, _), do: object

  @doc """
  Calculate new velocity when force is applied to an object for a period of time.
  """
  def apply_force(
        velocity = %LowPrecisionVector2D{},
        mass_kg,
        force_newtons = %LowPrecisionVector2D{},
        time_delta_millis
      ) do
    acceleration = LowPrecisionVector2D.mag(force_newtons) / mass_kg

    velocity_contribution =
      LowPrecisionVector2D.multiply_mag(force_newtons, time_delta_millis / 1000 * acceleration)

    LowPrecisionVector2D.add(velocity, velocity_contribution)
  end

  def apply_velocity(
        object = %PhysicsObject{
          position: position,
          velocity: velocity
        }
      ) do
    %PhysicsObject{object | position: LowPrecisionVector2D.add(position, velocity)}
  end

  @doc """
  Prevents an object from leaving the bounds of the arena.

  Position is capped at between 0 -> `arena_size` in the x and y dimensions and
  velocity is inverted along the axis of a collision.

  # Fun exercise: option to allow a wrapping world?

  #TODO: do proper collision detection with object's polygon instead of simply the position.
  """
  def apply_edge_collisions(object, arena_size)

  def apply_edge_collisions(
        object = %PhysicsObject{position: %LowPrecisionVector2D{x: x}},
        arena_size
      )
      when x > arena_size do
    apply_edge_collisions(
      %PhysicsObject{
        object
        | velocity:
            object.velocity
            |> LowPrecisionVector2D.invert_x()
            |> LowPrecisionVector2D.multiply_mag(object.rebound_velocity_adjustment),
          position: %LowPrecisionVector2D{object.position | x: arena_size},
          rebounds_remaining: calc_rebounds_remaining(object.rebounds_remaining)
      },
      arena_size
    )
  end

  def apply_edge_collisions(
        object = %PhysicsObject{position: %LowPrecisionVector2D{x: x}},
        arena_size
      )
      when x < 0 do
    apply_edge_collisions(
      %PhysicsObject{
        object
        | velocity:
            object.velocity
            |> LowPrecisionVector2D.invert_x()
            |> LowPrecisionVector2D.multiply_mag(object.rebound_velocity_adjustment),
          position: %LowPrecisionVector2D{object.position | x: 0},
          rebounds_remaining: calc_rebounds_remaining(object.rebounds_remaining)
      },
      arena_size
    )
  end

  def apply_edge_collisions(
        object = %PhysicsObject{position: %LowPrecisionVector2D{y: y}},
        arena_size
      )
      when y > arena_size do
    apply_edge_collisions(
      %PhysicsObject{
        object
        | velocity:
            object.velocity
            |> LowPrecisionVector2D.invert_y()
            |> LowPrecisionVector2D.multiply_mag(object.rebound_velocity_adjustment),
          position: %LowPrecisionVector2D{object.position | y: arena_size},
          rebounds_remaining: calc_rebounds_remaining(object.rebounds_remaining)
      },
      arena_size
    )
  end

  def apply_edge_collisions(
        object = %PhysicsObject{position: %LowPrecisionVector2D{y: y}},
        arena_size
      )
      when y < 0 do
    apply_edge_collisions(
      %PhysicsObject{
        object
        | velocity:
            object.velocity
            |> LowPrecisionVector2D.invert_y()
            |> LowPrecisionVector2D.multiply_mag(object.rebound_velocity_adjustment),
          position: %LowPrecisionVector2D{object.position | y: 0},
          rebounds_remaining: calc_rebounds_remaining(object.rebounds_remaining)
      },
      arena_size
    )
  end

  def apply_edge_collisions(object = %PhysicsObject{}, _), do: object

  @doc """
  Calculates the elastic collision between two objects.
  Returns a tuple of {PhysicalObject.t(), PhysicalObject.t()}.
  """
  def elastic_collision(obj1 = %PhysicsObject{}, obj2 = %PhysicsObject{}) do
    {
      %PhysicsObject{obj1 | velocity: compute_collision_for_one_oject(obj1, obj2)},
      %PhysicsObject{obj2 | velocity: compute_collision_for_one_oject(obj2, obj1)}
    }
  end

  # See: https://stackoverflow.com/questions/35211114/2d-elastic-ball-collision-physics
  defp compute_collision_for_one_oject(obj, other_obj) do
    mass_part = 2 * other_obj.mass / (obj.mass + other_obj.mass)

    position_delta = LowPrecisionVector2D.sub(obj.position, other_obj.position)

    LowPrecisionVector2D.sub(
      obj.velocity,
      LowPrecisionVector2D.multiply_mag(
        position_delta,
        mass_part *
          (LowPrecisionVector2D.dot(
             LowPrecisionVector2D.sub(obj.velocity, other_obj.velocity),
             position_delta
           ) /
             :math.pow(LowPrecisionVector2D.mag(position_delta), 2))
      )
    )
  end

  defp calc_rebounds_remaining(:unlimited), do: :unlimited
  defp calc_rebounds_remaining(n), do: n - 1
end
