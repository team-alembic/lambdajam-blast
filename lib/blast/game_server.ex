defmodule Blast.GameServer do
  @moduledoc """
  Holds the GameState for a running Game.

  Holds all user-generated events in a buffer and processes the events every 120th
  of a second to produce the next GameState (which will result in all connected
  clients being updated).
  """
  use GenServer

  import Phoenix.PubSub

  alias Blast.GameState

  @millis_per_server_frame 16

  def start_link(name: name = {_, _, {_, game_id}}) do
    GenServer.start_link(__MODULE__, [game_id], name: name)
  end

  def init([game_id]) do
    Process.send_after(self(), :process_events, @millis_per_server_frame)
    {:ok, {game_id, GameState.new(), []}}
  end

  def handle_call(:game_state, _from, state = {_, game_state, _}) do
    {:reply, game_state, state}
  end

  def handle_call(
        {:update_fighter_controls, player_id, values},
        _from,
        {game_id, game_state, event_buffer}
      ) do
    {:reply, :ok,
     {game_id, game_state, [{:update_fighter_controls, player_id, values} | event_buffer]}}
  end

  def handle_call({:add_player, player_id}, _from, {game_id, game_state, event_buffer}) do
    {:reply, :ok, {game_id, game_state, [{:add_player, player_id} | event_buffer]}}
  end

  def handle_info(:process_events, {game_id, game_state, event_buffer}) do
    next_game_state =
      game_state
      |> GameState.process_events(@millis_per_server_frame, event_buffer)

    broadcast(Blast.PubSub, "game/#{game_id}", {:game_state_updated, next_game_state})
    Process.send_after(self(), :process_events, @millis_per_server_frame)
    {:noreply, {game_id, next_game_state, []}}
  end

  def add_player(name, player_id) do
    GenServer.call(name, {:add_player, player_id})
  end

  def game_state(name) do
    GenServer.call(name, :game_state)
  end

  def update_fighter_controls(name, player_id, values = %{}) do
    GenServer.call(name, {:update_fighter_controls, player_id, values})
  end
end
