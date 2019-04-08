defmodule BlastWeb.SetSessionIDPlug do
  alias Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn1 = Conn.fetch_session(conn)
    if !Conn.get_session(conn1, :session_id) do
      Conn.put_session(conn1, :session_id, UUID.uuid4())
    else
      conn1
    end
  end
end