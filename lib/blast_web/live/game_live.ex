defmodule BlastWeb.GameLive do
  use Phoenix.LiveView

  import Phoenix.PubSub
  import Phoenix.HTML
  alias Phoenix.LiveView.Socket

  alias Blast.Player
  import Blast.Vector2D

  def render(assigns) do
    ~L"""
    <svg class="arena" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg">
      <rect x="0" y="0" width="1000" height="1000" />
      <%= for player <- Map.values(@game_state.players) do %>
        <%= draw_player(player) %>
      <% end %>
    </svg>
    """
  end

  def mount(assigns = %{:token => token}, socket) do
    if connected?(socket) do
      :ok = subscribe(Blast.PubSub, "game/#{token}")
    else
      :ok = unsubscribe(Blast.PubSub, "game/#{token}")
    end
    {:ok, assign(socket, assigns)}
  end

  def handle_info({:game_state_updated, game_state}, socket = %Socket{assigns: assigns}) do
    {:noreply, assign(socket, %{:game_state => game_state})}
  end

  defp draw_player(assigns = %Player{position: position, orientation: orientation}) do
    # A player is respresented by an equilateral triangle centred on `position` and rotated by `orientation`.

    ~L"""
    <polygon
      points="25 0, 35 50, 15 50"
      fill='white'
      transform='rotate(<%= signed_angle_between(north, unit(orientation)) %> 25 25)'
    />
    """
  end
end
