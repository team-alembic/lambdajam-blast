defmodule BlastWeb.GameLaunchController do
  @moduledoc """

  """
  use BlastWeb, :controller

  alias Blast.GameLaunchServer

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, _params) do
    {:ok, game_id} = GameLaunchServer.new()
    render(conn, "game.html", game_id: game_id)
  end
end
