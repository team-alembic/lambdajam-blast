defmodule Blast.GameState do
  defstruct [:players]

  def new() do
    %__MODULE__{players: MapSet.new()}
  end
end