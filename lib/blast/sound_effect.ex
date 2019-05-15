defmodule Blast.SoundEffect do
  @moduledoc """
  Represents a sound file to be played.

  Sounds effects will be rendered as HTML <audio> tags.

  Records the starting frame number so that sounds can be cleaned up from the
  rendered markup once they have finished playing.
  """

  use TypedStruct

  typedstruct enforce: true do
    field :id, integer(), default: 0
    field :file, String.t()
    field :starting_frame, integer()
  end

  alias Blast.SoundEffect

  @spec new(atom(), integer(), integer()) :: Blast.SoundEffect.t()
  def new(:shoot, id, starting_frame) when is_integer(id) and is_integer(starting_frame) do
    %SoundEffect{id: id, starting_frame: starting_frame, file: "/sfx/fighter-shoot.wav"}
  end
end
