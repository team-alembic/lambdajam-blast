defmodule Blast.GameServer do
  @moduledoc """
  Holds the GameState for a running Game.

  Holds all user-generated events in a buffer and processes the events every 120th
  of a second to produce the next GameState (which will result in all connected
  clients being updated).
  """
  use GenServer

  alias Blast.GameState

  @millis_per_server_frame 8

  def start_link([name: name = {_, _, {_, token}}]) do
    GenServer.start_link(__MODULE__, [token], name: name)
  end

  def init([token]) do
    Process.send_after(self(), :process_events, @millis_per_server_frame)
    {:ok, {token, GameState.new(), []}}
  end

  def handle_call({:add_player, player_id}, _from, {token, game_state, event_buffer}) do
    {:reply, :ok, {token, game_state, [{:add_player, player_id} | event_buffer]}}
  end

  def handle_call(:process_events, _from, {token, game_state, event_buffer}) do
    next_game_state = event_buffer
      |> Enum.reduce(game_state, fn (acc, event) ->
        GameState.process_event(acc, @millis_per_server_frame, event)
      end)
    Process.send_after(self(), :process_events, @millis_per_server_frame)
    {:reply, :ok, {token, next_game_state, []}}
  end

  def add_player(name, player_id) do
    GenServer.call(name, {:add_player, player_id})
  end
end

