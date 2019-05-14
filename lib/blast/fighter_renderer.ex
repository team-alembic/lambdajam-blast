defimpl Blast.GameObjectRenderer, for: Blast.Fighter do
  alias Blast.PhysicsObject
  alias Blast.Fighter
  alias Blast.Vector2D

  import Blast.RenderHelpers

  require Phoenix.LiveView
  import Phoenix.LiveView, only: :macros

  @impl true
  @spec render_object(Blast.Fighter.t()) :: Phoenix.LiveView.Rendered.t()
  def render_object(
        assigns = %Fighter{
          colour: colour,
          object: %PhysicsObject{polygon: polygon, position: position, orientation: orientation}
        }
      ) do
    ~L"""
    <polygon
      points="<%= render_polygon(polygon) %>"
      fill='<%= colour %>'
      transform='
        translate(<%= round(position.x - polygon_centre_x(polygon)) %>, <%= round(position.y - polygon_centre_y(polygon)) %>)
        rotate(<%= round(Vector2D.signed_angle_between(Vector2D.north(), Vector2D.unit(orientation))) %>
        <%= polygon_centre(polygon) %>)
      '
    />
    """
  end
end
