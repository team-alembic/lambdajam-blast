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

  def start_link([name: name = {_, _, {_, token}}]) do
    GenServer.start_link(__MODULE__, [token], name: name)
  end

  def init([token]) do
    Process.send_after(self(), :process_events, @millis_per_server_frame)
    {:ok, {token, GameState.new(), []}}
  end

  def handle_call(:game_state, _from, state = {_, game_state, _}) do
    {:reply, game_state, state}
  end

  def handle_call({:rotate_player_clockwise, player_id}, _from, {token, game_state, event_buffer}) do
    {:reply, :ok, {token, game_state, [{:rotate_player_clockwise, player_id} | event_buffer]}}
  end

  def handle_call({:rotate_player_anticlockwise, player_id}, _from, {token, game_state, event_buffer}) do
    {:reply, :ok, {token, game_state, [{:rotate_player_anticlockwise, player_id} | event_buffer]}}
  end

  def handle_call({:add_player, player_id}, _from, {token, game_state, event_buffer}) do
    {:reply, :ok, {token, game_state, [{:add_player, player_id} | event_buffer]}}
  end

  def handle_info(:process_events, {token, game_state, event_buffer}) do
    next_game_state = game_state
    |> GameState.process_events(@millis_per_server_frame, event_buffer)
    broadcast(Blast.PubSub, "game/#{token}", {:game_state_updated, next_game_state})
    Process.send_after(self(), :process_events, @millis_per_server_frame)
    {:noreply, {token, next_game_state, []}}
  end

  def add_player(name, player_id) do
    GenServer.call(name, {:add_player, player_id})
  end

  def rotate_player_clockwise(name, player_id) do
    GenServer.call(name, {:rotate_player_clockwise, player_id})
  end

  def rotate_player_anticlockwise(name, player_id) do
    GenServer.call(name, {:rotate_player_anticlockwise, player_id})
  end

  def game_state(name) do
    GenServer.call(name, :game_state)
  end
end

