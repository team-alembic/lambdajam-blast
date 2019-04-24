defmodule Blast.GameServer do
  @moduledoc """
  """
  use GenServer

  alias Blast.GameState

  def start_link([name: name]) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init([]) do
    {:ok, GameState.new()}
  end

  def handle_call({:add_player, player_id}, _from, game_state) do
    {:reply, :ok, game_state |> GameState.add_player(player_id)}
  end

  def add_player(name, player_id) do
    GenServer.call(name, {:add_player, player_id})
  end
end

