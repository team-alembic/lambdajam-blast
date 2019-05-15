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
end
