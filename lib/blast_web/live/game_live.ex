defmodule BlastWeb.GameLive do
  use Phoenix.LiveView

  import Phoenix.PubSub
  alias Phoenix.LiveView.Socket

  def render(assigns) do
    ~L"""
    <svg class="arena" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg">
      <rect x="0" y="0" width="1000" height="1000" />
    </svg>
    """
  end

  def mount(assigns = %{:token => token}, socket) do
    if connected?(socket) do
      :ok = subscribe(Blast.PubSub, "game/#{token}")
    else
      :ok = unsubscribe(Blast.PubSub, "game/#{token}")
    end
    {:ok, refresh(assigns, socket)}
  end

  defp refresh(assigns, socket) do
    IO.inspect({:assigns, assigns})
    socket
    |> assign(assigns, %{})
  end

  def handle_info({:game_state_updated, game_state}, socket = %Socket{assigns: assigns}) do
    IO.inspect({:assigns, assigns})
    IO.inspect({:game_state, game_state})
    # {:noreply, refresh(Map.merge(assigns, %{game_state: game_state}), socket)}
    {:noreply, assigns}
  end
end
