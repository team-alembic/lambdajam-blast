defmodule BlastWeb.LobbyLive do
  use Phoenix.LiveView

  alias Blast.PlayerService

  def render(assigns) do
    ~L"""
    <div>
      <h2>Lobby</h2>
      <div class="container">
        <%= assigns.player_count %> players connected
      </div>
    </div>
    """
  end

  def mount(session, socket) do
    {:ok, assign(socket, player_count: PlayerService.count())}
  end
end
