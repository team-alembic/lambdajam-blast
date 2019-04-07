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
      <div class="container">
        Current session has player? <%= if assigns.current_player, do: assigns.current_player.name %>
      </div>
    </div>
    """
  end

  def mount(session, socket) do
    IO.inspect(session: session)
    if connected?(socket) do
      :timer.send_interval(10, self(), {:tick, session, socket})
    end

    {:ok, refresh(session, socket)}
  end

  def handle_info({:tick, session, socket}, _) do
    {:noreply, refresh(session, socket)}
  end

  defp refresh(session, socket) do
    assign(socket,
      session: session,
      player_count: PlayerService.count(),
      current_player: PlayerService.get(session[:uuid]),
    )
  end
end
