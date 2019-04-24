defmodule BlastWeb.LobbyLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      GAME
    </div>
    """
  end

  def mount(session, socket) do
    {:ok, refresh(session, socket)}
  end

  defp refresh(_session, socket) do
    assign(socket, [])
  end
end
