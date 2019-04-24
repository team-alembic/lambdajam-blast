defmodule Blast.GameLaunchServer do
  @moduledoc """
  A singleton GenServer that launches supervised GameServers.

  # Responsibilities

  - Launches GameServers (supervised GenServers)
  - GameServers have a token (which will be used in the URL for joining a game)
  - GameSevers are registered in a Registry process and are identified by their token
  """
  use GenServer

  alias Blast.GameServer

  @counter_seed 0

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, @counter_seed}
  end

  def handle_call({:new}, _from, counter) do
    {:ok, token} = launch_game_server(counter)
    {:reply, token, counter + 1}
  end

  def new() do
    GenServer.call(__MODULE__, {:new})
  end

  defp launch_game_server(counter) do
    token = generate_token(counter)
    name = {:via, Registry, {GameServerRegistry, token}}
    {:ok, _} = GameServer.start_link([name: name])
    {:ok, token}
  end

  defp generate_token(counter) do
    :crypto.hash(:md5 , Integer.to_string(counter))
    |> Base.encode16()
    |> String.slice(1..4)
  end
end
