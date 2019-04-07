defmodule BlastWeb.PageController do
  use BlastWeb, :controller

  def index(conn, _params) do
    Phoenix.LiveView.Controller.live_render(conn, BlastWeb.LobbyLive, session: %{uuid: UUID.uuid4()})
  end
end
