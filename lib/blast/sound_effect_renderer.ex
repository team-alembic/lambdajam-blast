defmodule Blast.SoundEffectRenderer do
  require Phoenix.LiveView
  import Phoenix.LiveView, only: :macros

  alias Blast.SoundEffect

  @spec render(Blast.SoundEffect.t()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns = %SoundEffect{}) do
    ~L"""
    <span id="<%= @id %>" data-src="<%= @file %>">
    """
  end
end
