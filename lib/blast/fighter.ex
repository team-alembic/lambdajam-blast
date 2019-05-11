defmodule Blast.Fighter do
  @moduledoc """
  A fighter has an id (1 through to 4)

  The first player to join the game has id = 1, the second id = 2 and so on.

  The id is used to determine the initial positions.
  """

  alias Blast.Fighter

  use TypedStruct

  typedstruct enforce: true do
    field :id, pos_integer()
    field :engine_power, pos_integer(), default: 80
    field :charge_remaining, pos_integer(), default: 1000
    field :integrity, pos_integer(), default: 100
    field :object, PhysicsObject.t()
    field :colour, String.t(), default: "white"
  end

  alias Blast.Polygon

  def max_allowed_speed, do: 200
  def collision_velocity_multiplier, do: 0.75
  def polygon, do: Polygon.new([{25, 0}, {40, 50}, {25, 40}, {10, 50}])
  def mass, do: 500

  def new(values = %{}) do
    struct(Fighter, values)
  end
end