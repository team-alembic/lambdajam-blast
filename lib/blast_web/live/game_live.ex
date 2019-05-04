defmodule BlastWeb.GameLive do
  use Phoenix.LiveView

  import Phoenix.PubSub
  import Phoenix.HTML
  alias Phoenix.LiveView.Socket

  alias Blast.GameServer
  alias Blast.Player
  import Blast.Vector2D

  def render(assigns) do
    ~L"""
    <svg id="arena" class="arena" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg"
      phx-keydown="player_keydown"
      phx-keyup="player_keyup"
      phx-target="window"
     >
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

  def handle_event("player_" <> event_type, event_data, socket = %Socket{assigns: %{token: token, active_player: player_id}}) do
    [{pid, _}] = Registry.lookup(GameServerRegistry, token)
    handle_player_event(pid, player_id, event_type, event_data)
    {:noreply, socket}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

  defp draw_player(assigns = %Player{position: position, orientation: orientation}) do
    # A player is respresented by an equilateral triangle centred on `position` and rotated by `orientation`.

    ~L"""
    <polygon
      points="<%= player_polygon() %>"
      fill='white'
      transform='
        translate(<%= position.x - player_centre_x() %>, <%= position.y - player_centre_y() %>)
        rotate(<%= signed_angle_between(north, unit(orientation)) %> <%= player_polygon_centre() %>)
      '
    />
    """
  end

  defp player_polygon() do
    raw Player.vertices() |> Enum.map(fn (%{x: x, y: y}) -> "#{x} #{y}" end) |> Enum.join(", ")
  end

  defp player_polygon_centre() do
    %{x: x, y: y} = Player.centre()
    raw "#{x} #{y}"
  end

  defp player_centre_x() do
    %{x: x} = Player.centre()
    x
  end

  defp player_centre_y() do
    %{y: y} = Player.centre()
    y
  end

  defp handle_player_event(pid, player_id, event_type, event_data)
  defp handle_player_event(pid, player_id, "keydown", "ArrowLeft"), do: GameServer.set_player_turning(pid, player_id, :anticlockwise)
  defp handle_player_event(pid, player_id, "keyup", "ArrowLeft"), do: GameServer.set_player_turning(pid, player_id, :none)
  defp handle_player_event(pid, player_id, "keydown", "ArrowRight"), do: GameServer.set_player_turning(pid, player_id, :clockwise)
  defp handle_player_event(pid, player_id, "keyup", "ArrowRight"), do: GameServer.set_player_turning(pid, player_id, :none)
  defp handle_player_event(_, _, _, _), do: :ok
end
