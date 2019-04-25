defmodule Blast.Vector2DTest do
  use ExUnit.Case, async: true

  alias Blast.Vector2D

  test "vector magnitude" do
    assert Vector2D.mag(Vector2D.new(0, 0)) == 0
    assert Vector2D.mag(Vector2D.new(1, 0)) == 1
    assert Vector2D.mag(Vector2D.new(0, 1)) == 1
    assert_in_delta Vector2D.mag(Vector2D.new(1, 1)), 1.414, 0.01
  end

  test "conversion to unit vector (magnitude = 1)" do
    assert Vector2D.unit(Vector2D.new(0, 0)) == Vector2D.new(0, 0)
    assert Vector2D.unit(Vector2D.new(1, 0)) == Vector2D.new(1, 0)
    assert Vector2D.unit(Vector2D.new(0, 1)) == Vector2D.new(0, 1)

    new_vec = Vector2D.unit(Vector2D.new(2, 2))

    assert_in_delta new_vec.x, 0.707, 0.01
    assert_in_delta new_vec.y, 0.707, 0.01
    assert_in_delta Vector2D.mag(new_vec), 1, 0.0000001
  end

  # test "multiplication - cross product (vector x vector)" do
  #   assert Vector2D.mult(Vector2D.new(0, 0), Vector2D.new(0, 0)) == Vector2D.new(0, 0)
  # end
end
