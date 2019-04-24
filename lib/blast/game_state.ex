defmodule Blast.GameState do
  @moduledoc """
  The state of an in-progress Game and the logic to compute the next state
  of the game based on previous state + inputs.

  The state includes:

  - each player that has joined the game
  - the player sprite positions, orientations and velocities
  - the position and velocity vectors of any projectiles
  - the accumulated damage for each player
  - the score for each player
  """
  defstruct [:arena, :players]

  alias Blast.Player

  def new() do
    %__MODULE__{players: %{}}
  end

  def add_player(game_state = %__MODULE__{}, player_id) do
    %__MODULE__{game_state | players: Map.put_new(game_state.players, player_id, %Player{})}
  end
end