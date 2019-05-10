defmodule Blast.CollisionTest do
  use ExUnit.Case, async: true

  alias Blast.Vector2D
  alias Blast.Collision
  alias Blast.PhysicsObject
  alias Blast.Fighter
  alias Blast.Projectile

  test "when there are no fighers there are no collisions" do
    assert [] = Collision.detect(%{})
  end

  test "when there is one fighter there are no collisions" do
    assert [] = Collision.detect(%{
      {:fighter, "1"} => fighter_object()
    })
  end

  test "two far apart fighters do not collide" do
    assert [] = Collision.detect(%{
      {:fighter, "1"} => fighter_object(%{position: Vector2D.new(0, 0)}),
      {:fighter, "2"} => fighter_object(%{position: Vector2D.new(100, 100)})
    })
  end

  test "two close fighters do collide" do
    assert [{
      {:fighter, "1", _},
      {:fighter, "2", _}
    }] =
      Collision.detect(%{
        {:fighter, "1"} => fighter_object(%{position: Vector2D.new(0, 0)}),
        {:fighter, "2"} => fighter_object(%{position: Vector2D.new(10, 0)}),
        {:fighter, "3"} => fighter_object(%{position: Vector2D.new(81, 0)})
      })
  end

  test "all collision pairs are returned" do
    assert [{
      {:fighter, "1", _},
      {:fighter, "2", _}
    },{
      {:fighter, "1", _},
      {:fighter, "3", _}
    },{
      {:fighter, "2", _},
      {:fighter, "3", _}
    }] =
      Collision.detect(%{
        {:fighter, "1"} => fighter_object(%{position: Vector2D.new(0, 0)}),
        {:fighter, "2"} => fighter_object(%{position: Vector2D.new(10, 0)}),
        {:fighter, "3"} => fighter_object(%{position: Vector2D.new(20, 0)})
      })
  end

  test "fighter-projectile collision" do
    assert [{
      {:projectile, "2", _},
      {:fighter, "1", _}
    }] =
      Collision.detect(%{
        {:fighter, "1"} => fighter_object(%{position: Vector2D.new(0, 0)}),
        {:projectile, "2"} => projectile_object(%{position: Vector2D.new(10, 0)})
      })
  end

  defp fighter_object(values = %{} \\ %{}) do
    PhysicsObject.new(%{
      polygon: Fighter.polygon(),
      velocity: Vector2D.new(0, 0),
      orientation: Vector2D.new(0, 0),
      position: Vector2D.new(0, 0),
      max_allowed_speed: 100,
      mass: 1000
    } |> Map.merge(values))
  end

  defp projectile_object(values = %{}) do
    PhysicsObject.new(%{
      polygon: Projectile.polygon(),
      velocity: Vector2D.new(0, 0),
      orientation: Vector2D.new(0, 0),
      position: Vector2D.new(0, 0),
      max_allowed_speed: 1000,
      mass: 10
    } |> Map.merge(values))
  end
end