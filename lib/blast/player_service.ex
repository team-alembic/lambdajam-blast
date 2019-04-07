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

  def handle_call({:new, session_id, name}, _from, players) do
    new_player = %Player{session_id: session_id, name: name}
    {:reply, new_player, Map.put(players, session_id, new_player)}
  end

  def handle_call({:get, session_id}, _from, players) do
    {:reply, Map.get(players, session_id), players}
  end

  def handle_call({:count}, _from, players) do
    {:reply, length(Map.keys(players)), players}
  end

  def new(session_id, name) do
    GenServer.call(__MODULE__, {:new, session_id, name})
  end

  def get(session_id) do
    GenServer.call(__MODULE__, {:get, session_id})
  end

  def count() do
    GenServer.call(__MODULE__, {:count})
  end
end