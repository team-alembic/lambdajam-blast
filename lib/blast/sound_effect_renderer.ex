defmodule Blast.SoundEffectRenderer do
  require Phoenix.LiveView
  import Phoenix.LiveView, only: :macros

  alias Blast.SoundEffect

  @spec render(Blast.SoundEffect.t()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns = %SoundEffect{}) do
    ~L"""
    <audio id="<%= @id %>" autoplay>
      <source src="<%= @file %>" type="audio/wav">
    </audio>
    """
  end
end
