defmodule BlastWeb.SetPlayerIDPlug do
  alias Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn1 = Conn.fetch_session(conn)
    if !Conn.get_session(conn1, :player_id) do
      Conn.put_session(conn1, :player_id, UUID.uuid4())
    else
      conn1
    end
  end
end