defmodule Blast.SoundEffect do
  @moduledoc """
  Represents a sound file to be played.

  Sounds effects will be rendered as HTML <audio> tags.

  Records the starting frame number so that sounds can be cleaned up from the
  rendered markup once they have finished playing.
  """

  use TypedStruct

  typedstruct enforce: true do
    field :file, String.t()
    field :starting_frame, integer()
  end

  alias Blast.SoundEffect

  @spec new(atom(), integer()) :: Blast.SoundEffect.t()
  def new(:shoot, starting_frame) when is_integer(starting_frame) do
    %SoundEffect{starting_frame: starting_frame, file: "/sfx/fighter-shoot.wav"}
  end

  def new(:die, starting_frame) when is_integer(starting_frame) do
    %SoundEffect{starting_frame: starting_frame, file: "/sfx/fighter-die.wav"}
  end

  def new(:spawn, starting_frame) when is_integer(starting_frame) do
    %SoundEffect{starting_frame: starting_frame, file: "/sfx/fighter-spawn.wav"}
  end

  def new(:hit, starting_frame) when is_integer(starting_frame) do
    %SoundEffect{starting_frame: starting_frame, file: "/sfx/fighter-hit.wav"}
  end
end
