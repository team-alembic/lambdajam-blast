defmodule Blast.GameState do
  @moduledoc """
  The state of an in-progress Game and the logic to compute the next state
  of the game based on previous state + inputs.
  """

  alias Blast.Collision
  alias Blast.Fighter
  alias Blast.FighterControls
  alias Blast.GameState
  alias Blast.PhysicsObject
  alias Blast.Projectile
  alias Blast.Vector2D
  alias Blast.SoundEffect

  use TypedStruct

  typedstruct enforce: true do
    field :arena_size, pos_integer(), default: 1000
    field :max_players, pos_integer(), default: 4
    field :controls, %{String.t() => FighterControls.t()}, default: %{}
    field :fighters, %{integer() => Fighter.t()}, default: %{}
    field :projectiles, %{integer() => Projectile.t()}, default: []
    field :sounds, list(), default: []
    field :frame_number, integer(), default: 0
    field :next_sound_id, integer(), default: 0
  end

  def new() do
    %GameState{}
  end

  def fighter(%GameState{fighters: fighters}, player_id) when is_binary(player_id) do
    fighters[player_id]
  end

  def fighter_count(%GameState{fighters: fighters}), do: map_size(fighters)

  def process_events(game_state = %GameState{}, frame_millis, event_buffer) do
    event_buffer
    |> Enum.uniq()
    |> Enum.reduce(game_state, fn event, acc ->
      process_event(acc, event)
    end)
    |> inc_frame_number()
    |> apply_fighter_controls(frame_millis)
    |> update_positions(:fighters)
    |> update_positions(:projectiles)
    |> apply_collisions()
    |> reap(:projectiles)
    |> reap(:sounds)
  end

  # Processes one user-generated event and returns a new GameState.
  # i.e. updates positions of all of the players and projectiles.
  defp process_event(game_state, event)
  defp process_event(game_state, {:add_player, player_id}), do: add_player(game_state, player_id)

  defp process_event(game_state, {:update_fighter_controls, player_id, changes}) do
    %GameState{controls: %{^player_id => controls}} = game_state

    %GameState{
      game_state
      | controls:
          Map.put(
            game_state.controls,
            player_id,
            FighterControls.update(controls, changes)
          )
    }
  end

  defp process_event(game_state, event) do
    IO.inspect("Unknown event: #{inspect(event)}")
    game_state
  end

  defp initial_orientation(1), do: Vector2D.unit(Vector2D.new(1, 1))
  defp initial_orientation(2), do: Vector2D.unit(Vector2D.new(-1, 1))
  defp initial_orientation(3), do: Vector2D.unit(Vector2D.new(1, -1))
  defp initial_orientation(4), do: Vector2D.unit(Vector2D.new(-1, -1))

  defp initial_colour(1), do: "blue"
  defp initial_colour(2), do: "yellow"
  defp initial_colour(3), do: "orange"
  defp initial_colour(4), do: "pink"

  defp initial_position(1), do: Vector2D.new(50, 50)
  defp initial_position(2), do: Vector2D.new(950, 50)
  defp initial_position(3), do: Vector2D.new(50, 950)
  defp initial_position(4), do: Vector2D.new(950, 950)

  defp add_player(game_state = %GameState{}, player_id) do
    num_fighters = fighter_count(game_state)

    if can_add_player?(game_state, player_id) do
      fighter_id = num_fighters + 1

      update(game_state, %{
        controls: Map.put_new(game_state.controls, player_id, make_controls(fighter_id)),
        fighters: Map.put_new(game_state.fighters, fighter_id, make_fighter(fighter_id))
      })
    else
      game_state
    end
  end

  defp can_add_player?(game_state, player_id) do
    num_fighters = fighter_count(game_state)
    num_fighters < game_state.max_players && !Map.has_key?(game_state.controls, player_id)
  end

  defp make_controls(fighter_id) do
    FighterControls.new(%{fighter_id: fighter_id})
  end

  defp make_fighter(fighter_id) do
    Fighter.new(%{
      id: fighter_id,
      colour: initial_colour(fighter_id),
      object:
        PhysicsObject.new(%{
          position: initial_position(fighter_id),
          orientation: initial_orientation(fighter_id),
          mass: Fighter.mass(),
          polygon: Fighter.polygon(),
          max_allowed_speed: Fighter.max_allowed_speed()
        })
    })
  end

  defp apply_fighter_controls(game_state, frame_millis) do
    game_state.controls
    |> Enum.reduce(game_state, fn {_, controls}, acc ->
      {fighter, projectiles} =
        FighterControls.apply(
          controls,
          {Map.get(game_state.fighters, controls.fighter_id), []},
          frame_millis
        )

      new_sounds =
        projectiles
        |> Enum.with_index()
        |> Enum.map(fn {_, index} ->
          SoundEffect.new(:shoot, game_state.next_sound_id + index, game_state.frame_number)
        end)

      update(acc, %{
        fighters: Map.put(acc.fighters, controls.fighter_id, fighter),
        projectiles: projectiles ++ acc.projectiles,
        sounds: game_state.sounds ++ new_sounds,
        next_sound_id: game_state.next_sound_id + length(new_sounds)
      })
    end)
  end

  defp update_positions(game_state, :fighters) do
    update(game_state, %{
      fighters:
        Enum.reduce(game_state.fighters, %{}, fn {id, fighter}, acc ->
          Map.put(
            acc,
            id,
            Fighter.update(fighter, %{
              object:
                fighter.object
                |> PhysicsObject.apply_velocity()
                |> PhysicsObject.apply_edge_collisions(game_state.arena_size)
            })
          )
        end)
    })
  end

  defp update_positions(game_state, :projectiles) do
    update(game_state, %{
      projectiles:
        Enum.map(game_state.projectiles, fn projectile ->
          Projectile.update(projectile, %{
            object:
              projectile.object
              |> PhysicsObject.apply_velocity()
              |> PhysicsObject.apply_edge_collisions(game_state.arena_size)
          })
        end)
    })
  end

  defp apply_collisions(game_state) do
    Collision.detect(Map.values(game_state.fighters), game_state.projectiles)
    |> Enum.reduce(game_state, &collide/2)
  end

  defp collide({fighter1 = %Fighter{}, fighter2 = %Fighter{}}, game_state) do
    {obj1_updated, obj2_updated} =
      PhysicsObject.elastic_collision(fighter1.object, fighter2.object)

    update(game_state, %{
      fighters:
        Map.merge(game_state.fighters, %{
          fighter1.id =>
            Fighter.update(fighter1, %{
              integrity: fighter1.integrity - 5,
              object: obj1_updated
            }),
          fighter2.id =>
            Fighter.update(fighter2, %{
              integrity: fighter2.integrity - 5,
              object: obj2_updated
            })
        })
    })
  end

  defp collide({projectile = %Projectile{}, fighter = %Fighter{}}, game_state) do
    {_, updated_fighter_obj} = PhysicsObject.elastic_collision(projectile.object, fighter.object)

    firing_fighter = Map.get(game_state.fighters, projectile.fired_by_fighter_id)

    update(game_state, %{
      fighters:
        Map.merge(game_state.fighters, %{
          fighter.id =>
            Fighter.update(fighter, %{
              integrity: fighter.integrity - 10,
              object: updated_fighter_obj,
              score: fighter.score - 10
            }),
          firing_fighter.id =>
            Fighter.update(firing_fighter, %{
              score: firing_fighter.score + 10
            })
        }),
      projectiles: List.delete(game_state.projectiles, projectile)
    })
  end

  defp collide(_, game_state), do: game_state

  defp reap(game_state = %GameState{}, :projectiles) do
    update(game_state, %{
      projectiles:
        game_state.projectiles
        |> Enum.filter(fn projectile ->
          projectile.object.rebounds_remaining == :unlimited ||
            projectile.object.rebounds_remaining >= 0
        end)
    })
  end

  defp reap(game_state = %GameState{frame_number: frame_number, sounds: sounds}, :sounds) do
    update(game_state, %{
      sounds: sounds |> Enum.reject(&(&1.starting_frame < frame_number))
    })
  end

  def inc_frame_number(game_state = %GameState{frame_number: frame_number}) do
    %GameState{game_state | frame_number: frame_number + 1}
  end

  def count_projectiles(game_state) do
    length(game_state.projectiles)
  end

  def game_objects(%GameState{fighters: fighters, projectiles: projectiles}) do
    List.flatten([Map.values(fighters) | projectiles])
  end

  defp update(game_state = %GameState{}, values = %{}) do
    struct(game_state, values)
  end
end
