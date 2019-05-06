defmodule Blast.Physics do
  @moduledoc """
  Functions for performing Newtonian physics calculations on objects.
  """

  import Blast.Vector2D
  alias Blast.Vector2D


  @doc """
  Given an object with a position, velocity, mass, calculate the new position and velocity when a force
  is applied for a period of time.
  """
  def apply_force(
    position = %Vector2D{},
    velocity = %Vector2D{},
    mass_kg,
    force_newtons = %Vector2D{},
    time_delta_millis
  ) do

    # velocity_contribution = multiply_mag(force_newtons, time_delta_millis / 1000)
    # new_velocity = add(velocity, velocity_contribution)
    # new_position = add(position, new_velocity)

    velocity_contribution = multiply_mag(force_newtons, (time_delta_millis / 1000))
    new_velocity = add(velocity, velocity_contribution)
    new_position = add(position, new_velocity)

    {new_position, new_velocity}
  end
end
