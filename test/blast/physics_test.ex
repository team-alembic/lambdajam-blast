defmodule Blast.PhysicsTest do
  use ExUnit.Case, async: true

  import Blast.Vector2D
  import Blast.Physics

  setup do
    {:ok, %{
      object: %{
        position: new(0, 0),
        velocity: new(0, 0),
        mass: 1000,
      },
      force: 10000,
      time_delta_millis: 1000
    }}
  end

  test "applying 0 force does not change velocity", %{
    object: %{position: position, velocity: velocity, mass: mass},
    force: force,
    time_delta_millis: time_delta_millis} do

    {new_position, new_velocity} = apply_force(position, velocity, mass, force, time_delta_millis)

    assert new_position = position
    assert new_velocity = velocity
  end
end