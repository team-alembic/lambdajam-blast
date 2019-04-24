defmodule BlastWeb.GameController do
  @moduledoc """
  Connects a player to a running Game.

  The Game is identified by the `token` parameter.

  The player is identified by the `player_id` in the session.
  """
  use BlastWeb, :controller

  alias Plug.Conn
  import Phoenix.LiveView.Controller

  alias Blast.GameServer

  @doc """
  Joins a Player identified `player_id` from the session to a Game identified by `token`.

  This is an idempotent action: if the player is already joined the operation will be a no-op.

  Returns 404 if the Game is not found.
  """
  def join_game(conn, %{"token" => token}) do
    player_id = Conn.get_session(conn, :player_id)
    do_get(conn, Registry.lookup(GameServerRegistry, token), token, player_id)
  end

  defp do_get(conn, [{pid, _}], token, player_id) do
    :ok = GameServer.add_player(pid, player_id)
    live_render(conn, BlastWeb.GameLive, session: %{token: token, player_id: player_id})
  end
  defp do_get(conn, _, _, _) do
    put_status(conn, :not_found)
  end
end
