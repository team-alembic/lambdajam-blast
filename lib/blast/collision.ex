defmodule Blast.Collision do
  @moduledoc """
  Detects collisions between projectiles and fighters and fighters on fighters.

  The algorithm is a very naive collision detector. The number of collisions to check is
  O(F * P) where F is number of fighters and P is number of projectiles.

  A collision occurs between objects when their distance between their centre points
  is less than or equal half the maximum dimension of the object's polygon.

  It's tractable because projectile-projectile collisions are not checked.
  """

  alias Blast.LowPrecisionVector2D
  alias Blast.Polygon

  @doc """
  `fighters` is a list of %Fighter{}
  `projectiles` is a list of %Projectile{}

  Return value is a mixed list of {%Fighter{}, %Fighter{}} and {%Projectile{}, %Fighter{}}.
  """
  def detect(fighters, projectiles) do
    Enum.concat(
      fighter_fighter_pairs(fighters),
      fighter_projectile_pairs(fighters, projectiles)
    )
    |> Enum.filter(&collided?/1)
  end

  defp fighter_fighter_pairs([]), do: []
  defp fighter_fighter_pairs([_]), do: []

  defp fighter_fighter_pairs(fighters) do
    for f1 <- fighters, f2 <- fighters, f1 !== f2 do
      [f1, f2]
      |> Enum.sort()
      |> List.to_tuple()
    end
    |> Enum.uniq()
  end

  defp fighter_projectile_pairs(fighters, projectiles) do
    for fighter <- fighters, projectile <- projectiles, do: {projectile, fighter}
  end

  defp collided?({obj1, obj2}) do
    r1 = Polygon.bounding_sphere_radius(obj1.object.polygon)
    r2 = Polygon.bounding_sphere_radius(obj2.object.polygon)

    distance_between_centres =
      LowPrecisionVector2D.distance_between(obj1.object.position, obj2.object.position)

    distance_between_centres <= r1 + r2
  end
end
