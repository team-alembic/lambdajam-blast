defmodule Blast.CollisionTest do
  use ExUnit.Case, async: true

  alias Blast.Vector2D
  alias Blast.Collision
  alias Blast.PhysicsObject
  alias Blast.Fighter
  alias Blast.Projectile

  test "when there are no fighters there are no collisions" do
    assert [] = Collision.detect([], [])
  end

  test "when there is one fighter there are no collisions" do
    assert [] = Collision.detect([fighter(%{id: 1})], [])
  end

  test "two far apart fighters do not collide" do
    assert [] = Collision.detect([
      fighter(%{id: 1, position: Vector2D.new(0, 0)}),
      fighter(%{id: 2, position: Vector2D.new(100, 100)})
    ], [])
  end

  test "two close fighters do collide" do
    assert [{
      %{id: 1},
      %{id: 2}
    }] =
      Collision.detect([
        fighter(%{id: 1, position: Vector2D.new(0, 0)}),
        fighter(%{id: 2, position: Vector2D.new(10, 0)}),
        fighter(%{id: 3, position: Vector2D.new(81, 0)})
      ], [])
  end

  test "all collision pairs are returned" do
    assert [{
      %{id: 1},
      %{id: 2}
    },{
      %{id: 1},
      %{id: 3}
    },{
      %{id: 2},
      %{id: 3}
    }] =
      Collision.detect([
        fighter(%{id: 1, position: Vector2D.new(0, 0)}),
        fighter(%{id: 2, position: Vector2D.new(10, 0)}),
        fighter(%{id: 3, position: Vector2D.new(20, 0)})
      ], [])
  end

  test "fighter-projectile collision" do
    assert [{
      %{fired_by_fighter_id: 2},
      %{id: 1}
    }] =
      Collision.detect(
        [fighter(%{id: 1, position: Vector2D.new(0, 0)})],
        [projectile(fighter(%{id: 2, position: Vector2D.new(5, 0)}))]
      )
  end

  defp fighter(values = %{} \\ %{}) do
    %Fighter{
      id: values.id,
      object: PhysicsObject.new(%{
        polygon: Fighter.polygon(),
        velocity: Vector2D.new(0, 0),
        orientation: Vector2D.new(0, 0),
        position: Vector2D.new(0, 0),
        max_allowed_speed: 100,
        mass: 1000
      } |> Map.merge(values))
    }
  end

  defp projectile(fighter), do: Projectile.fired_by(fighter)
end