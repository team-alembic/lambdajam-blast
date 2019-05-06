defmodule Blast.Player do
  @moduledoc """
  A player has an id (1 through to 4)

  The first player to join the game has id = 1, the second id = 2 and so on.

  The id is used to determine the initial positions.

  `position` is a unit Vector2D
  """
  defstruct [
    # Player ID
    :id,
    # Position of the player
    :position,
    # Orientation of the player (offset from north).
    # This is the direction in which thrust will be applied.
    :orientation,
    # Direction of motion of the player (offset from north) as a vector (direction and magnitude)
    :velocity,
    # Whether the platyer is turning (:left, :right, :not_turning)
    :turning,
    # Whether the thruster is on or off (:on, :off)
    :thrusters,
    # Mass of space ship in kilograms
    :mass,
    # Engine power in newtons
    :engine_power,
    # The polygon
    :polygon
  ]

  import Blast.Vector2D
  import Blast.Physics
  alias Blast.Polygon

  @player_defaults %{
    :velocity => new(0, 0),
    :turning => :not_turning,
    :thrusters => :off,
    :engine_power => 4,
    :mass => 500,
    :polygon => Polygon.new([{25, 0}, {40, 50}, {25, 40}, {10, 50}])
  }

  def new(values = %{}) do
    struct(__MODULE__, Map.merge(values, @player_defaults))
  end

  def set_turning(player = %__MODULE__{}, option) when option in [:right, :left, :not_turning] do
    %__MODULE__{player | turning: option}
  end

  def set_thrusters(player = %__MODULE__{}, on_or_off) when on_or_off in [:on, :off] do
    %__MODULE__{player | thrusters: on_or_off}
  end

  @doc """
  Rotate a player right with angular velocity of 1.5 seconds for full rotation.
  """
  def turn_right(player = %__MODULE__{}, frame_millis) do
    %__MODULE__{player | orientation: rotate(player.orientation, (frame_millis / 1500.0) * 360)}
  end

  @doc """
  Rotate a player left with angular velocity of 1.5 seconds for full rotation.
  """
  def turn_left(player = %__MODULE__{}, frame_millis) do
    %__MODULE__{player | orientation: rotate(player.orientation, -((frame_millis / 1500.0) * 360))}
  end

  @doc """
  Apply thrust in the direction of the player's orientation.

  Uses Newtonian mechanics to calculate an updated velocity for an acceleration over `frame_millis`.
  """
  def apply_thrust(player = %__MODULE__{
    velocity: velocity,
    mass: mass,
    orientation: orientation,
    engine_power: engine_power,
    thrusters: :on
  },
    frame_millis
  ) do
    force_vector = multiply_mag(orientation, engine_power)
    new_velocity = apply_force(velocity, mass, force_vector, frame_millis)
    %__MODULE__{player | velocity: new_velocity}
  end
  def apply_thrust(player = %__MODULE__{}, _), do: player

  def apply_velocity(player = %__MODULE__{
    position: position,
    velocity: velocity
  }) do
    %__MODULE__{player | position: add(position, velocity)}
  end

  def apply_turn(player = %__MODULE__{turning: :left}, frame_millis), do: turn_left(player, frame_millis)
  def apply_turn(player = %__MODULE__{turning: :right}, frame_millis), do: turn_right(player, frame_millis)
  def apply_turn(player = %__MODULE__{turning: :not_turning, }, _), do: player
end