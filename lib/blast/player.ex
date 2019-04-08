defmodule Blast.Player do
  @moduledoc """
  A player has:

  - name (unique)
  - a session_id (unique)
  - sprite (also unique)
  """
  defstruct [:name, :session_id]
end