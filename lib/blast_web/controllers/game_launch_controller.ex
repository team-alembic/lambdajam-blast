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
    redirect(conn, to: Routes.game_path(conn, :show, game_id))
  end
end
