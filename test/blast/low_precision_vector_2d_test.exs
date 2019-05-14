defmodule Blast.LowPrecisionVector2DTest do
  use ExUnit.Case, async: true

  alias Blast.LowPrecisionVector2D

  @delta 0.001

  test "vector magnitude" do
    assert LowPrecisionVector2D.mag(LowPrecisionVector2D.new(0, 0)) == 0
    assert LowPrecisionVector2D.mag(LowPrecisionVector2D.new(1, 0)) == 1
    assert LowPrecisionVector2D.mag(LowPrecisionVector2D.new(0, 1)) == 1

    assert_in_delta LowPrecisionVector2D.mag(LowPrecisionVector2D.new(1, 1)),
                    1.414,
                    @delta
  end

  test "conversion to unit vector (magnitude = 1)" do
    assert LowPrecisionVector2D.unit(LowPrecisionVector2D.new(0, 0)) ==
             LowPrecisionVector2D.new(0, 0)

    assert LowPrecisionVector2D.unit(LowPrecisionVector2D.new(1, 0)) ==
             LowPrecisionVector2D.new(1, 0)

    assert LowPrecisionVector2D.unit(LowPrecisionVector2D.new(0, 1)) ==
             LowPrecisionVector2D.new(0, 1)

    new_vec = LowPrecisionVector2D.unit(LowPrecisionVector2D.new(2, 2))

    assert_in_delta new_vec.x, 0.71, @delta
    assert_in_delta new_vec.y, 0.71, @delta
    assert_in_delta LowPrecisionVector2D.mag(new_vec), 1, @delta
  end

  test "multiplication - 2D dot product (vector x vector) -> scalar" do
    assert LowPrecisionVector2D.dot(
             LowPrecisionVector2D.new(0, 0),
             LowPrecisionVector2D.new(0, 0)
           ) == 0
  end

  test "rotation" do
    result_1 =
      LowPrecisionVector2D.rotate(
        LowPrecisionVector2D.unit(LowPrecisionVector2D.new(0, 1)),
        -90
      )

    assert_in_delta result_1.x, 1, @delta
    assert_in_delta result_1.y, 0, @delta

    result_2 =
      LowPrecisionVector2D.rotate(
        LowPrecisionVector2D.unit(LowPrecisionVector2D.new(0, 1)),
        90
      )

    assert_in_delta result_2.x, -1, @delta
    assert_in_delta result_2.y, 0, @delta
  end

  test "dot product (angle between two vectors)" do
    assert LowPrecisionVector2D.signed_angle_between(
             LowPrecisionVector2D.new(1, 1),
             LowPrecisionVector2D.new(1, 1)
           ) ==
             0

    assert_in_delta LowPrecisionVector2D.signed_angle_between(
                      LowPrecisionVector2D.new(0, 1),
                      LowPrecisionVector2D.new(1, 0)
                    ),
                    -90,
                    @delta

    assert_in_delta LowPrecisionVector2D.signed_angle_between(
                      LowPrecisionVector2D.new(1, 1),
                      LowPrecisionVector2D.new(-1, -1)
                    ),
                    180,
                    @delta

    assert_in_delta LowPrecisionVector2D.signed_angle_between(
                      LowPrecisionVector2D.new(-1, -1),
                      LowPrecisionVector2D.new(1, 1)
                    ),
                    180,
                    @delta

    assert_in_delta LowPrecisionVector2D.signed_angle_between(
                      LowPrecisionVector2D.new(1, 0),
                      LowPrecisionVector2D.new(0, 1)
                    ),
                    90,
                    @delta
  end

  test "subtraction" do
    v1 = LowPrecisionVector2D.new(0, 1)
    v2 = LowPrecisionVector2D.new(1, 0)
    assert LowPrecisionVector2D.sub([v1, v2]) == LowPrecisionVector2D.new(-1, 1)
  end
end
