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
    velocity = %Vector2D{},
    mass_kg,
    force_newtons = %Vector2D{},
    time_delta_millis
  ) do
    acceleration = mag(force_newtons) / mass_kg
    velocity_contribution =
      multiply_mag(force_newtons, (time_delta_millis / 1000) * acceleration)
    add(velocity, velocity_contribution)
  end
end
