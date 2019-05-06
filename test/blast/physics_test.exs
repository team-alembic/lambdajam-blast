defmodule Blast.PhysicsTest do
  use ExUnit.Case, async: true

  alias Blast.Vector2D
  alias Blast.Physics

  setup do
    {:ok, %{
      object: %{
        velocity: Vector2D.new(0, 0),
        mass: 1000,
      },
      force: Vector2D.new(0, 0),
      time_delta_millis: 1000
    }}
  end

  test "applying 0 force does not change velocity", %{
    object: %{velocity: velocity, mass: mass},
    force: force,
    time_delta_millis: time_delta_millis
  } do
    new_velocity =
      Physics.apply_force(velocity, mass, force, time_delta_millis)

    assert new_velocity == velocity
  end
end