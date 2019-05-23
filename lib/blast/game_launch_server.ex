defmodule Blast.GameLaunchServer do
  @moduledoc """
  A singleton GenServer that launches supervised GameServers.

  # Responsibilities

  - Launches GameServers (supervised GenServers)
  - GameServers have a game_id (which will be used in the URL for joining a game)
  - GameSevers are registered in a Registry process and are identified by their game_id
  """
  use GenServer

  alias Blast.GameServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, nil}
  end

  def handle_call({:new}, _from, _) do
    {:ok, game_id} = launch_game_server()
    {:reply, {:ok, game_id}, nil}
  end

  def new() do
    GenServer.call(__MODULE__, {:new})
  end

  defp launch_game_server() do
    game_id = generate_token()
    name = {:via, Registry, {GameServerRegistry, game_id}}
    {:ok, _} = GameServer.start_link(name: name)
    {:ok, game_id}
  end

  defp generate_token() do
    :crypto.hash(:md5, Integer.to_string(Enum.random(0..999_999_999_999_999)))
    |> Base.encode16()
    |> String.slice(1..4)
  end
end
