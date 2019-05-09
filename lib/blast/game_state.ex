defmodule Blast.GameState do
  @moduledoc """
  The state of an in-progress Game and the logic to compute the next state
  of the game based on previous state + inputs.
  """

  alias Blast.Fighter
  alias Blast.FighterControls
  alias Blast.PhysicsObject
  alias Blast.Vector2D
  alias Blast.Collision

  use TypedStruct

  typedstruct enforce: true do
    field :arena_size, pos_integer(), default: 1000
    field :max_players, pos_integer(), default: 4
    field :fighters, %{integer() => Fighter.t()}, default: %{}
    field :controls, %{integer() => FighterControls.t()}, default: %{}
    field :objects, %{{(:fighter | :projectile), integer()} => PhysicsObject.t()}, default: %{}
  end

  def new() do
    %__MODULE__{}
  end

  def player(%__MODULE__{fighters: fighters}, player_id) do
    fighters[player_id]
  end

  defp fighter_count(%__MODULE__{fighters: fighters}) do
    map_size(fighters)
  end

  def process_events(game_state, frame_millis, event_buffer) do
    event_buffer
    |> Enum.uniq()
    |> Enum.reduce(game_state, fn (event, acc) ->
      process_event(acc, event)
    end)
    |> apply_fighter_controls(frame_millis)
    |> update_positions()
    |> check_collisions()
  end

  # Processes one user-generated event and returns a new GameState.
  # i.e. updates positions of all of the players and projectiles.
  defp process_event(game_state, event)
  defp process_event(game_state, {:add_player, player_id}) do
    game_state |> add_player(player_id)
  end
  defp process_event(game_state, {:update_fighter_controls, fighter_id, %{:turning => turning}}) do
    %__MODULE__{controls: %{^fighter_id => controls}} = game_state
    %__MODULE__{game_state | controls: %{ game_state.controls | fighter_id => controls |> FighterControls.set_turning(turning)}}
  end
  defp process_event(game_state, {:update_fighter_controls, fighter_id, %{:thrusters => thrusting}}) do
    %__MODULE__{controls: %{^fighter_id => controls}} = game_state
    %__MODULE__{game_state | controls: %{ game_state.controls | fighter_id => controls |> FighterControls.set_thrusters(thrusting)}}
  end
  defp process_event(game_state, {:update_fighter_controls, fighter_id, %{:guns => firing}}) do
    %__MODULE__{controls: %{^fighter_id => controls}} = game_state
    %__MODULE__{game_state | controls: %{ game_state.controls | fighter_id => controls |> FighterControls.set_guns(firing)}}
  end
  defp process_event(game_state, event) do
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


  # Adds a player with `player_id` to the game.
  # There's quite a bit of book keeping here: we need to add an associated
  # Fighter struct, a FighterControls struct and a PhysicalObject.
  defp add_player(game_state = %__MODULE__{max_players: max_players, fighters: fighters, controls: controls, objects: objects}, player_id) do
    num_fighters = fighter_count(game_state)
    if num_fighters < max_players do
      fighter_id = num_fighters + 1
      %__MODULE__{game_state |
        fighters: Map.put_new(
          fighters,
          player_id,
          Fighter.new(%{
            id: fighter_id
          })
        ),
        controls: Map.put_new(
          controls,
          player_id,
          FighterControls.new(%{fighter_id: fighter_id})
        ),
        objects: Map.put_new(
          objects,
          {:fighter, player_id},
          PhysicsObject.new(%{
            position: initial_positition(fighter_id),
            orientation: initial_orientation(fighter_id),
            mass: Fighter.mass(),
            polygon: Fighter.polygon(),
            max_allowed_speed: Fighter.max_allowed_speed()
          })
        )
      }
    else
      game_state
    end
  end

  defp apply_fighter_controls(game_state, frame_millis) do
    game_state.controls
    |> Enum.reduce(game_state, fn ({fighter_id, controls}, acc) ->
      {fighter, object, projectiles} = FighterControls.apply(
        controls, {
          Map.get(game_state.fighters, fighter_id),
          Map.get(game_state.objects, {:fighter, fighter_id}),
          []
        },
        frame_millis
      )

      %__MODULE__{ acc |
        fighters: Map.put(game_state.fighters, fighter_id, fighter),
        objects:
          game_state.objects
          |> Map.put({:fighter, fighter_id}, object)
          |> add_projectiles(projectiles)
      }
    end)
  end

  defp update_positions(game_state) do
    %__MODULE__{game_state | objects:
      Enum.reduce(game_state.objects, %{}, fn ({key, object}, acc) ->
        Map.put(
          acc,
          key,
          object
          |> PhysicsObject.apply_velocity()
          |> PhysicsObject.apply_edge_collisions(game_state.arena_size)
        )
      end)
    }
  end

  defp add_projectiles(objects, projectiles) do
    projectiles
    |> Enum.reduce(objects, fn (projectile, acc) ->
      acc |> Map.put({:projectile, Enum.random(0..999999999999)}, projectile)
    end)
  end

  defp check_collisions(game_state) do
    _collisions = Collision.detect(game_state.objects)
    # TODO: do something with the collision information
    game_state
  end
end