defmodule BlastWeb.GameLaunchController do
  @moduledoc """

  """
  use BlastWeb, :controller

  alias Plug.Conn

  alias Blast.GameLaunchServer

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, _params) do
    {:ok, token} = GameLaunchServer.new()
    render(conn, "game.html", token: token)
  end
end

