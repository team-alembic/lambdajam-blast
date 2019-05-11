defmodule BlastWeb.GameController do
  @moduledoc """
  Connects a player to a running Game.

  The Game is identified by the `game_id` parameter.

  The player is identified by the `player_id` in the session.
  """
  use BlastWeb, :controller

  alias Plug.Conn
  import Phoenix.LiveView.Controller

  alias Blast.GameServer

  @doc """
  Joins a Fighter identified `player_id` from the session to a Game identified by `game_id`.

  This is an idempotent action: if the player is already joined the operation will be a no-op.

  Returns 404 if the Game is not found.
  """
  def join_game(conn, %{"game_id" => game_id}) do
    player_id = Conn.get_session(conn, :player_id)
    do_get(conn, Registry.lookup(GameServerRegistry, game_id), game_id, player_id)
  end

  defp do_get(conn, [{pid, _}], game_id, player_id) do
    :ok = GameServer.add_player(pid, player_id)
    game_state = GameServer.game_state(pid)

    live_render(conn, BlastWeb.GameLive,
      session: %{
        game_id: game_id,
        active_player: player_id,
        game_state: game_state
      }
    )
  end

  defp do_get(conn, _, game_id, _) do
    send_resp(conn, :not_found, "Game #{game_id} not found")
  end
end
