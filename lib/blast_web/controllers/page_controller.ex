defmodule BlastWeb.PageController do
  use BlastWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
