defmodule BlastWeb.GameLive do
  use Phoenix.LiveView

  import Phoenix.PubSub
  import Phoenix.HTML
  alias Phoenix.LiveView.Socket

  alias Blast.GameServer
  alias Blast.Polygon
  alias Blast.PhysicsObject
  import Blast.Vector2D

  def render(assigns) do
    # TODO use SVG `defs` to define shapes once and reuse with different positions,
    # transforms and rendering styles. This will drastically reduce the size of the
    # rendered SVG DOM.
    ~L"""
    <svg id="arena" class="arena" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg"
      phx-keydown="player_keydown"
      phx-keyup="player_keyup"
      phx-target="window"
     >
      <rect x="0" y="0" width="1000" height="1000" fill="#000"/>
      <%= for object <- Map.values(@game_state.objects) do %>
        <%= draw_object(object) %>
      <% end %>
      <rect x="0" y="0" width="1000" height="1000" fill-opacity="0" stroke="#F00" stroke-width="10"/>
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

  def handle_info({:game_state_updated, game_state}, socket = %Socket{}) do
    {:noreply, assign(socket, %{:game_state => game_state})}
  end

  def handle_event("player_" <> event_type, event_data, socket = %Socket{assigns: %{token: token, active_player: player_id}}) do
    [{pid, _}] = Registry.lookup(GameServerRegistry, token)
    handle_player_event(pid, player_id, event_type, event_data)
    {:noreply, socket}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

  defp draw_object(assigns = %PhysicsObject{position: position, orientation: orientation, polygon: polygon}) do
    ~L"""
    <polygon
      points="<%= render_polygon(polygon) %>"
      fill='white'
      transform='
        translate(<%= position.x - polygon_centre_x(assigns) %>, <%= position.y - polygon_centre_y(assigns) %>)
        rotate(<%= signed_angle_between(north(), unit(orientation)) %> <%= polygon_centre(assigns) %>)
      '
    />
    """
  end

  defp render_polygon(%Polygon{vertices: vertices}) do
    raw vertices |> Enum.map(fn (%{x: x, y: y}) -> "#{x} #{y}" end) |> Enum.join(", ")
  end

  defp polygon_centre(%{polygon: polygon}) do
    %{x: x, y: y} = Polygon.centre(polygon)
    raw "#{x} #{y}"
  end

  defp polygon_centre_x(%{polygon: polygon}) do
    %{x: x} = Polygon.centre(polygon)
    x
  end

  defp polygon_centre_y(%{polygon: polygon}) do
    %{y: y} = Polygon.centre(polygon)
    y
  end

  defp handle_player_event(pid, player_id, event_type, event_data)
  defp handle_player_event(pid, player_id, "keydown", "ArrowLeft"), do: GameServer.update_fighter_controls(pid, player_id, %{:turning => :left})
  defp handle_player_event(pid, player_id, "keyup", "ArrowLeft"), do: GameServer.update_fighter_controls(pid, player_id, %{:turning => :not_turning})
  defp handle_player_event(pid, player_id, "keydown", "ArrowRight"), do: GameServer.update_fighter_controls(pid, player_id, %{:turning => :right})
  defp handle_player_event(pid, player_id, "keyup", "ArrowRight"), do: GameServer.update_fighter_controls(pid, player_id, %{:turning => :not_turning})
  defp handle_player_event(pid, player_id, "keydown", "ArrowUp"), do: GameServer.update_fighter_controls(pid, player_id, %{:thrusters => :on})
  defp handle_player_event(pid, player_id, "keyup", "ArrowUp"), do: GameServer.update_fighter_controls(pid, player_id, %{:thrusters => :off})
  defp handle_player_event(pid, player_id, "keydown", " "), do: GameServer.update_fighter_controls(pid, player_id, %{:guns => :firing})
  defp handle_player_event(pid, player_id, "keyup", " "), do: GameServer.update_fighter_controls(pid, player_id, %{:guns => :not_firing})
  defp handle_player_event(_, _, _, _), do: :ok
end
