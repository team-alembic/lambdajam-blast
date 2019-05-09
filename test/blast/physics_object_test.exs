defmodule Blast.PhysicsTest do
  use ExUnit.Case, async: true

  alias Blast.Vector2D
  alias Blast.PhysicsObject
  alias Blast.Polygon

  setup do
    {:ok, %{
      object: %PhysicsObject{
        polygon: Polygon.new([{0,0}, {1, 1}, {0, 1}]),
        velocity: Vector2D.new(0, 0),
        max_allowed_speed: 100,
        orientation: Vector2D.new(0, 0),
        position: Vector2D.new(0, 0),
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
      PhysicsObject.apply_force(velocity, mass, force, time_delta_millis)

    assert new_velocity == velocity
  end
end