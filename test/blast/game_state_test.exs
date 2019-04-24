defmodule Blast.GameStateTest do
  use ExUnit.Case, async: true

  alias Blast.GameState
  alias Blast.Player

  setup do
    [state: GameState.new()]
  end

  test "initial state", %{state: state} do
    assert state == %GameState{players: %{}}
  end

  test "add player", %{state: state} do
    assert GameState.add_player(state, "1234") == %GameState{players: %{"1234" => %Player{}}}
  end

  test "add player - idempotence", %{state: state} do
    assert state
      |> GameState.add_player("1234")
      |> GameState.add_player("1234") == %GameState{players: %{"1234" => %Player{}}}
  end
end
