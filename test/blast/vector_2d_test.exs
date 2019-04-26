defmodule Blast.Vector2DTest do
  use ExUnit.Case, async: true

  import Blast.Vector2D

  test "vector magnitude" do
    assert mag(new(0, 0)) == 0
    assert mag(new(1, 0)) == 1
    assert mag(new(0, 1)) == 1
    assert_in_delta mag(new(1, 1)), 1.414, 0.01
  end

  test "conversion to unit vector (magnitude = 1)" do
    assert unit(new(0, 0)) == new(0, 0)
    assert unit(new(1, 0)) == new(1, 0)
    assert unit(new(0, 1)) == new(0, 1)

    new_vec = unit(new(2, 2))

    assert_in_delta new_vec.x, 0.707, 0.01
    assert_in_delta new_vec.y, 0.707, 0.01
    assert_in_delta mag(new_vec), 1, 0.0000001
  end

  test "multiplication - 2D cross product (vector x vector) -> scalar" do
    assert cross(new(0, 0), new(0, 0)) == 0
  end

  test "multiplication - 2D dot product (vector x vector) -> scalar" do
    assert dot(new(0, 0), new(0, 0)) == 0
  end

  test "dot product (angle between two vectors)" do
    assert signed_angle_between(new(1, 1), new(1, 1)) == 0
    assert_in_delta signed_angle_between(new(0, 1), new(1, 0)), -90, 0.0001
    assert_in_delta signed_angle_between(new(1, 1), new(-1, -1)), 180, 0.0001
    assert_in_delta signed_angle_between(new(-1, -1), new(1, 1)), 180, 0.0001
    assert_in_delta signed_angle_between(new(1, 0), new(0, 1)), 90, 0.0001
  end
end
