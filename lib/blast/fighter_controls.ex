defmodule Blast.FighterControls do
  @moduledoc """
  Defines a struct that contains the state of the controls and a public function `apply/3`
  that returns a tuple of updated values to be incorporated into the game state.
  """

  alias Blast.PhysicsObject
  alias Blast.Projectile
  alias Blast.Fighter

  use TypedStruct

  typedstruct enforce: true do
    field :fighter_id, pos_integer()
    field :turning, :left | :right | :not_turning, default: :not_turning
    field :thrusters, :on | :off, default: :off
    field :guns, :firing | :not_firing, default: :not_firing
  end

  def new(values = %{}) do
    struct(__MODULE__, values)
  end

  @doc """
  Sets a value indicating that the player is initiating a left or right turn or not turning at all.
  """
  def set_turning(controls = %__MODULE__{}, option) when option in [:right, :left, :not_turning] do
    %__MODULE__{controls | turning: option}
  end

  @doc """
  Sets a value indicating that the player is firing the thrusters or not.
  """
  def set_thrusters(controls = %__MODULE__{}, on_or_off) when on_or_off in [:on, :off] do
    %__MODULE__{controls | thrusters: on_or_off}
  end

  @doc """
  Sets a value indicating that the player is firing the guns or not.
  """
  def set_guns(controls = %__MODULE__{}, firing) when firing in [:firing, :not_firing] do
    %__MODULE__{controls | guns: firing}
  end

  @doc """
  Applies the control input and returns a tuple of new structs to be incorporated into the game state.

  Returns a tuple of updated state of the form {Fighter.t(), PhysicsObject.t(), list(Projectile.t())}
  """
  def apply(controls, t = {%Fighter{}, %PhysicsObject{}, []}, time_delta) do
    t
    |> apply_turn(controls, time_delta)
    |> apply_thrust(controls, time_delta)
    |> fire_guns(controls)
  end

  # Makes the PhysicsObject actually perform the turn.
  # `current_state` is of the form `{fighter, object, projectiles}`
  defp apply_turn(current_state, controls, time_delta)

  defp apply_turn(t = {_, _, _}, %__MODULE__{turning: :not_turning}, _), do: t

  defp apply_turn(t = {_, object = %PhysicsObject{}, _}, %__MODULE__{turning: turn}, time_delta) do
    put_elem(t, 1, PhysicsObject.rotate(object, turn, time_delta))
  end

  # Applies thrust to the PhysicsObject.
  # This only updates the velocity of the object - not the position.
  # `current_state` is of the form `{fighter, object, projectiles}`
  defp apply_thrust(current_state, controls, time_delta)

  # Thrusters are off, so nothing to do here.
  defp apply_thrust(t = {_, _, _}, %__MODULE__{thrusters: :off}, _), do: t

  # Thrusters are on, so apply fighter's engine power as thrust to the physics object.
  defp apply_thrust(t = {%Fighter{engine_power: newtons}, object = %PhysicsObject{}, _}, %__MODULE__{thrusters: :on}, time_delta) do
    put_elem(t, 1, PhysicsObject.apply_thrust(object, newtons, time_delta))
  end

  # Spawns projectiles when guns are fired.
  # `current_state` is of the form `{fighter, object, projectiles}`
  defp fire_guns(current_state, controls)

  # Nothing to do when the guns aren't firing.
  defp fire_guns(t = {_, _, _}, %__MODULE__{guns: :not_firing}), do: t

  # Create a new projectile and deplete the figher's energy weapon charge.
  defp fire_guns({fighter = %Fighter{charge_remaining: charge}, object, projectiles}, %__MODULE__{guns: :firing}) when charge > 0 do
    {%Fighter{fighter | charge_remaining: charge - 1}, object, [Projectile.fired_by_object(object) | projectiles]}
  end

  # The fighter's weapon charge has been depleted so we can't fire the guns.
  defp fire_guns(t = {_, _, _}, _), do: t
end