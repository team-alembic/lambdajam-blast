defmodule BlastWeb.GameLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <svg class="arena" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg">
      <rect x="0" y="0" width="1000" height="1000" />
    </svg>
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
