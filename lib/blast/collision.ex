defmodule Blast.Collision do
  @moduledoc """
  Detects collisions between projectiles and fighters and fighters on fighters.

  The algorithm is a very naive collision detector. The number of collisions to check is
  O(F * P) where F is number of fighters and P is number of projectiles.

  AS collision occurs between objects when their distance between their centre points
  is less than or equal half the maximum dimension of the object's polygon.

  It's tractable because projectile-projectile collisions are not checked.
  """

  alias Blast.Vector2D
  alias Blast.Polygon

  @doc """
  `objects` is enumerable of {{kind, id}, physics_object}.

  Return value is a MapSet of [{kind, id, object}, {kind, id, object}].

  The order of the objects in the collision list has no semantic meaning.

  In order to ensure collisions between the same objects are not reported twice
  (i.e. by changing the order of the items in the 2-element list), the list is
  sorted before insertion into the MapSet.
  """
  def detect(fighters, projectiles) do
    fighter_pairs = unique_pairs(fighters)

    fighter_projectile_pairs =
      fighters
      |> Enum.reduce([], fn fighter, acc ->
        projectiles
        |> Enum.reduce(acc, fn projectile, pairs ->
          [{projectile, fighter} | pairs]
        end)
      end)

    all_pairs = Enum.concat(fighter_pairs, fighter_projectile_pairs)

    all_pairs
    |> Enum.filter(fn {obj1, obj2} ->
      collided?(obj1, obj2)
    end)
  end

  defp collided?(obj1, obj2) do
    r1 = Polygon.bounding_sphere_radius(obj1.object.polygon)
    r2 = Polygon.bounding_sphere_radius(obj2.object.polygon)

    distance_between_centres =
      Vector2D.distance_between(obj1.object.position, obj2.object.position)

    distance_between_centres <= r1 + r2
  end

  # Gets unique pairs of values.
  # WARNING: O(N^2) code ahead!
  defp unique_pairs([]), do: []
  defp unique_pairs([_]), do: []

  defp unique_pairs(things) do
    cross_product = for a <- things, b <- things, a != b, do: [a, b]

    cross_product
    |> Enum.reduce(MapSet.new(), fn [a, b], acc ->
      MapSet.put(acc, List.to_tuple(Enum.sort([a, b])))
    end)
    |> Enum.into([])
  end
end
