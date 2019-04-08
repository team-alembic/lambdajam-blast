defmodule BlastWeb.PageController do
  use BlastWeb, :controller

  alias Plug.Conn
  import Phoenix.LiveView.Controller

  def index(conn, _params) do
    session_id = Conn.get_session(conn, :session_id)
    live_render(
      conn,
      BlastWeb.LobbyLive,
      session: %{session_id: session_id}
    )
  end
end
