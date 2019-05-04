defmodule Blast.GameStateTest do
  use ExUnit.Case, async: true

  alias Blast.GameState
  alias Blast.Vector2D

  setup do
    [state: GameState.new()]
  end

  test "initial state", %{state: state} do
    assert ^state = %GameState{players: %{}, arena_size: 1000}
  end

  test "add player", %{state: state} do
    assert state |> GameState.player_count() == 0
    new_state = state |> GameState.add_player("1234")
    assert new_state |> GameState.player_count() == 1
  end

  test "add player - idempotence", %{state: state} do
    assert state |> GameState.player_count() == 0
    new_state = state
      |> GameState.add_player("1234")
      |> GameState.add_player("1234")
    assert new_state |> GameState.player_count() == 1
  end

  test "only allows four players", %{state: state} do
    new_state = state
      |> GameState.add_player("1")
      |> GameState.add_player("2")
      |> GameState.add_player("3")
      |> GameState.add_player("4")
      |> GameState.add_player("5")

    assert length(Map.keys(new_state.players)) == 4
  end

  test "player initial positions and orientations", %{state: state} do
    new_state = state
      |> GameState.add_player("1")
      |> GameState.add_player("2")
      |> GameState.add_player("3")
      |> GameState.add_player("4")

    # Player 1 is top-left pointing towards the centre (offset 50, 50)
    p1_expected_orientation = Vector2D.new(1, 1) |> Vector2D.unit()
    p1_expected_position = Vector2D.new(50, 50)
    assert GameState.player(new_state, "1").position == p1_expected_position
    assert GameState.player(new_state, "1").orientation == p1_expected_orientation

    # Player 2 is top-right pointing towards the centre
    p2_expected_orientation = Vector2D.new(-1, 1) |> Vector2D.unit()
    p2_expected_position = Vector2D.new(950, 50)
    assert GameState.player(new_state, "2").position == p2_expected_position
    assert GameState.player(new_state, "2").orientation == p2_expected_orientation

    # Player 3 is bottom-left pointing towards the centre
    p3_expected_orientation = Vector2D.new(1, -1) |> Vector2D.unit()
    p3_expected_position = Vector2D.new(50, 950)
    assert GameState.player(new_state, "3").position == p3_expected_position
    assert GameState.player(new_state, "3").orientation == p3_expected_orientation

    # Player 4 is bottom-right pointing towards the centre
    p4_expected_orientation = Vector2D.new(-1, -1) |> Vector2D.unit()
    p4_expected_position = Vector2D.new(950, 950)
    assert GameState.player(new_state, "4").position == p4_expected_position
    assert GameState.player(new_state, "4").orientation == p4_expected_orientation
  end

  test "player_turn_clockwise event", %{state: state} do
    initial_state = state |> GameState.add_player("1")
    next_state = initial_state |> GameState.process_event(16, {:player_turn_clockwise, "1"})
    assert next_state.players["1"].orientation != initial_state.players["1"].orientation
  end

  test "duplicate events are ignored"
end
