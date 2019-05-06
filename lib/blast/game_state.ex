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

  The arena size is a square of dimensions `@arena_size` in world coordinates.
  """
  defstruct [:arena_size, :players]

  @max_players 4
  @arena_size 1000

  alias Blast.Player
  alias Blast.Vector2D

  def new() do
    %__MODULE__{arena_size: @arena_size, players: %{}}
  end

  def player(%__MODULE__{players: players}, player_id) do
    players[player_id]
  end

  def player_count(%__MODULE__{players: players}) do
    length(Map.keys(players))
  end

  def process_events(game_state, frame_millis, event_buffer) do
    event_buffer
    |> Enum.uniq()
    |> Enum.reduce(game_state, fn (event, acc) ->
      process_event(acc, frame_millis, event)
    end)
    |> update_players(frame_millis)
  end

  @doc """
  Processes one user-generated event and returns a new GameState.

  i.e. updates positions of all of the players and projectiles.

  NOTE: this function does not process any damage.
  """
  def process_event(game_state, frame_millis, event)
  def process_event(game_state, _, {:add_player, player_id}) do
    game_state |> add_player(player_id)
  end
  def process_event(game_state, frame_millis, {:update_player, player_id, %{:turning => turning}}) do
    %__MODULE__{players: %{^player_id => player}} = game_state
    %__MODULE__{game_state | players: %{ game_state.players | player_id => %Player{player | turning: turning}}}
  end
  def process_event(game_state, frame_millis, {:update_player, player_id, %{:thrusters => thrusting}}) do
    %__MODULE__{players: %{^player_id => player}} = game_state
    %__MODULE__{game_state | players: %{ game_state.players | player_id => %Player{player | thrusters: thrusting} }}
  end
  def process_event(game_state, _, event) do
    IO.inspect("Unknown event: #{inspect(event)}")
    game_state
  end

  defp initial_positition(1), do: Vector2D.new(50, 50)
  defp initial_positition(2), do: Vector2D.new(950, 50)
  defp initial_positition(3), do: Vector2D.new(50, 950)
  defp initial_positition(4), do: Vector2D.new(950, 950)

  defp initial_orientation(1), do: Vector2D.unit(Vector2D.new(1, 1))
  defp initial_orientation(2), do: Vector2D.unit(Vector2D.new(-1, 1))
  defp initial_orientation(3), do: Vector2D.unit(Vector2D.new(1, -1))
  defp initial_orientation(4), do: Vector2D.unit(Vector2D.new(-1, -1))

  def add_player(game_state = %__MODULE__{}, player_id) do
    num_players = player_count(game_state)
    if num_players < @max_players do
      %__MODULE__{game_state | players: Map.put_new(
        game_state.players,
        player_id,
        Player.new(%{
          id: num_players + 1,
          position: initial_positition(num_players + 1),
          orientation: initial_orientation(num_players + 1)
        })
      )}
    else
      game_state
    end
  end

  def update_players(game_state, frame_millis) do
    %__MODULE__{players: players} = game_state
    %__MODULE__{game_state | players: players |> Enum.reduce(%{}, fn ({player_id, player}, acc) ->
      acc
      |> Map.put(player_id,
          player
          |> Player.apply_turn(frame_millis)
          |> Player.apply_thrust(frame_millis)
          |> Player.apply_velocity()
      )
    end)}
  end
end