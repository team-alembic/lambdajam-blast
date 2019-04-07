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
    if connected?(socket) do
      :timer.send_interval(10, self(), :tick)
    end

    {:ok, assign(socket, player_count: PlayerService.count())}
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, player_count: PlayerService.count())}
  end
end
