defmodule BlastWeb.GameLive do
  use Phoenix.LiveView

  import Phoenix.PubSub
  alias Phoenix.LiveView.Socket

  alias Blast.GameServer
  alias Blast.GameState
  alias Blast.GameObjectRenderer
  alias Blast.SoundEffectRenderer

  def render(assigns) do
    # TODO use SVG `defs` to define shapes once and reuse with different positions,
    # transforms and rendering styles. This will drastically reduce the size of the
    # rendered SVG DOM.
    ~L"""
    <div class="active-game">
      <div class="stats">
        <ul>
          <%= for fighter <- GameState.fighters_in_order(@game_state) do %>
            <li>
              <h2 style="color: <%= fighter.colour %>;">Player #<%= fighter.id %></h2>
              <ul class="player-stats">
                <li>Score: <%= fighter.score %></li>
                <li>Deaths: <%= fighter.deaths %></li>
                <li>Shields: <%= fighter.shields %></li>
                <li>Ammo: <%= fighter.ammo_remaining %></li>
              </ul>
            </li>
          <% end %>
        </ul>
      </div>
      <svg id="arena" class="arena" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg"
        phx-keydown="player_keydown"
        phx-keyup="player_keyup"
        phx-target="window"
      >
        <rect x="0" y="0" width="1000" height="1000" fill="#000"/>
        <%= for game_object <- GameState.active_game_objects(@game_state) do %>
          <%= GameObjectRenderer.render_object(game_object) %>
        <% end %>
        <rect x="0" y="0" width="1000" height="1000" fill-opacity="0" stroke="#F00" stroke-width="10"/>
      </svg>
      <div style="display: hidden;" id="sound-fx">
        <%= for sound <- @game_state.sounds do %>
          <%= SoundEffectRenderer.render(sound) %>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(assigns = %{:game_id => game_id}, socket) do
    if connected?(socket) do
      :ok = subscribe(Blast.PubSub, "game/#{game_id}")
    else
      :ok = unsubscribe(Blast.PubSub, "game/#{game_id}")
    end

    {:ok, assign(socket, assigns)}
  end

  def handle_info({:game_state_updated, game_state}, socket = %Socket{}) do
    {:noreply, assign(socket, %{:game_state => game_state})}
  end

  def handle_event(
        "player_" <> event_type,
        event_data,
        socket = %Socket{assigns: %{game_id: game_id, active_player: player_id}}
      ) do
    [{pid, _}] = Registry.lookup(GameServerRegistry, game_id)
    handle_player_event(pid, player_id, event_type, event_data)
    {:noreply, socket}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

  defp handle_player_event(pid, player_id, event_type, event_data)

  defp handle_player_event(pid, player_id, "keydown", "ArrowLeft"),
    do: GameServer.update_fighter_controls(pid, player_id, %{:turning => :left})

  defp handle_player_event(pid, player_id, "keyup", "ArrowLeft"),
    do: GameServer.update_fighter_controls(pid, player_id, %{:turning => :not_turning})

  defp handle_player_event(pid, player_id, "keydown", "ArrowRight"),
    do: GameServer.update_fighter_controls(pid, player_id, %{:turning => :right})

  defp handle_player_event(pid, player_id, "keyup", "ArrowRight"),
    do: GameServer.update_fighter_controls(pid, player_id, %{:turning => :not_turning})

  defp handle_player_event(pid, player_id, "keydown", "ArrowUp"),
    do: GameServer.update_fighter_controls(pid, player_id, %{:thrusters => :on})

  defp handle_player_event(pid, player_id, "keyup", "ArrowUp"),
    do: GameServer.update_fighter_controls(pid, player_id, %{:thrusters => :off})

  defp handle_player_event(pid, player_id, "keydown", " "),
    do: GameServer.update_fighter_controls(pid, player_id, %{:guns => :firing})

  defp handle_player_event(pid, player_id, "keyup", " "),
    do: GameServer.update_fighter_controls(pid, player_id, %{:guns => :not_firing})

  defp handle_player_event(_, _, _, _), do: :ok
end
