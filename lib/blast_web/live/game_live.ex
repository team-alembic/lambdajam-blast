defmodule BlastWeb.GameLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      GAME
    </div>
    """
  end

  def mount(assigns, socket) do
    {:ok, refresh(assigns, socket)}
  end

  defp refresh(assigns, socket) do
    socket
    |> assign(assigns, %{})
  end
end
