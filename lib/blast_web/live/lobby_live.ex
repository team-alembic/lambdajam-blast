defmodule BlastWeb.LobbyLive do
  use Phoenix.LiveView

  alias Blast.PlayerService

  def render(assigns) do
    ~L"""
    <div>
      <h2>Lobby: <%= assigns.player_count %> players connected!</h2>
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, player_count: PlayerService.count())}
  end
end
