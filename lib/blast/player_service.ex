defmodule Blast.PlayerService do
  @moduledoc """
  CRUD operations for players.

  A player has:
  - name (unique)
  - sprite (also unique)

  The DB of players is a map keyed by the player's name.
  """
  use GenServer

  alias Blast.Player

  def start_link([players: players]) when is_map(players) do
    GenServer.start_link(__MODULE__, players, name: __MODULE__)
  end

  def init(players) do
    {:ok, players}
  end

  def handle_call({:new, name}, _from, players) do
    new_player = %Player{name: name}
    {:reply, new_player, Map.put(players, name, new_player)}
  end

  def handle_call({:get, name}, _from, players) do
    {:reply, Map.get(players, name), players}
  end

  def handle_call({:count}, _from, players) do
    {:reply, length(Map.keys(players)), players}
  end

  def new(name) do
    GenServer.call(__MODULE__, {:new, name})
  end

  def get(name) do
    GenServer.call(__MODULE__, {:get, name})
  end

  def count() do
    GenServer.call(__MODULE__, {:count})
  end
end