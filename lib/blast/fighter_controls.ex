defmodule Blast.FighterControls do
  @moduledoc """
  Defines a struct that contains the state of the controls and a public function `apply/3`
  that returns a tuple of updated values to be incorporated into the game state.
  """

  alias Blast.PhysicsObject
  alias Blast.Projectile
  alias Blast.Fighter
  alias Blast.FighterControls

  use TypedStruct

  typedstruct enforce: true do
    field :fighter_id, pos_integer()
    field :turning, :left | :right | :not_turning, default: :not_turning
    field :thrusters, :on | :off, default: :off
    field :guns, :firing | :not_firing, default: :not_firing
  end

  def new(values = %{}) do
    struct(FighterControls, values)
  end

  @doc """
  Returns a new FighterControls struct with fields updated from `values`.
  """
  def update(controls, values)

  def update(controls = %FighterControls{}, values = %{turning: turning})
      when turning in [:right, :left, :not_turning] do
    update(struct(controls, values), Map.delete(values, :turning))
  end

  def update(controls = %FighterControls{}, values = %{thrusters: thrusters})
      when thrusters in [:on, :off] do
    update(struct(controls, values), Map.delete(values, :thrusters))
  end

  def update(controls = %FighterControls{}, values = %{guns: guns})
      when guns in [:firing, :not_firing] do
    update(struct(controls, values), Map.delete(values, :guns))
  end

  def update(controls = %FighterControls{}, _), do: controls

  @doc """
  Applies the control input and returns a tuple of new structs to be incorporated into the game state.

  Returns a tuple of updated state of the form {Fighter.t(), list(Projectile.t())}
  """
  def apply(controls, fighter_and_projectiles = {%Fighter{}, []}, time_delta, frame_number) do
    fighter_and_projectiles
    |> apply_turn(controls, time_delta)
    |> apply_thrust(controls, time_delta)
    |> fire_guns(controls, frame_number)
  end

  # Makes the PhysicsObject actually perform the turn.
  # `current_state` is of the form {Fighter.t(), list(Projectile.t())}
  defp apply_turn(current_state, controls, time_delta)

  defp apply_turn({fighter, projectiles}, %FighterControls{turning: :not_turning}, _),
    do: {fighter, projectiles}

  defp apply_turn({fighter, projectiles}, %FighterControls{turning: turn}, time_delta) do
    {
      %Fighter{
        fighter
        | object: PhysicsObject.rotate(fighter.object, turn, time_delta)
      },
      projectiles
    }
  end

  # Applies thrust to the PhysicsObject.
  # This only updates the velocity of the object - not the position.
  # `current_state` is of the form `{fighter, object, projectiles}`
  defp apply_thrust(current_state, controls, time_delta)

  # Thrusters are off, so nothing to do here.
  defp apply_thrust({fighter, projectiles}, %FighterControls{thrusters: :off}, _),
    do: {fighter, projectiles}

  # Thrusters are on, so apply fighter's engine power as thrust to the physics object.
  defp apply_thrust(
         {fighter = %Fighter{engine_power: newtons}, projectiles},
         %FighterControls{thrusters: :on},
         time_delta
       ) do
    {
      %Fighter{
        fighter
        | object: PhysicsObject.apply_thrust(fighter.object, newtons, time_delta)
      },
      projectiles
    }
  end

  # Spawns projectiles when guns are fired.
  # `current_state` is of the form `{fighter, object, projectiles}`
  defp fire_guns(current_state, controls, frame_number)

  # Nothing to do when the guns aren't firing.
  defp fire_guns({fighter, projectiles}, %FighterControls{guns: :not_firing}, _),
    do: {fighter, projectiles}

  # Create a new projectile and deplete the figher's energy weapon ammo.
  defp fire_guns(
         {fighter = %Fighter{ammo_remaining: ammo, gun_last_fired_frame: gun_last_fired_frame},
          projectiles},
         %FighterControls{
           guns: :firing
         },
         frame_number
       )
       when ammo > 0 and gun_last_fired_frame <= frame_number - 8 do
    {
      %Fighter{
        fighter
        | ammo_remaining: ammo - 1,
          gun_last_fired_frame: frame_number
      },
      [Projectile.fired_by(fighter) | projectiles]
    }
  end

  # The fighter's weapon ammo has been depleted so we can't fire the guns.
  defp fire_guns({fighter, projectiles}, _, _), do: {fighter, projectiles}
end
