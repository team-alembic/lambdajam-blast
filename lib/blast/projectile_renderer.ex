defimpl Blast.GameObjectRenderer, for: Blast.Projectile do
  alias Blast.PhysicsObject
  alias Blast.Projectile

  require Phoenix.LiveView
  import Phoenix.LiveView, only: :macros

  @impl true
  def render_object(
        assigns = %Projectile{
          object: %PhysicsObject{position: position}
        }
      ) do
    ~L"""
    <circle
      cx="<%= round(position.x) %>"
      cy="<%= round(position.y) %>"
      r="3"
      opacity='1'
      fill='yellow'
     />
    """
  end
end
