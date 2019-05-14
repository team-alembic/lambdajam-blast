defimpl Blast.GameObjectRenderer, for: Blast.Fighter do
  alias Blast.LowPrecisionVector2D
  alias Blast.PhysicsObject
  alias Blast.Fighter
  alias Blast.Vector2D

  import Blast.RenderHelpers

  require Phoenix.LiveView
  import Phoenix.LiveView, only: :macros

  @impl true
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
        translate(<%= position.x - polygon_centre_x(polygon) %>, <%= position.y - polygon_centre_y(polygon) %>)
        rotate(<%= LowPrecisionVector2D.signed_angle_between(LowPrecisionVector2D.new(Vector2D.north()), LowPrecisionVector2D.unit(orientation)) %> <%= polygon_centre(polygon) %>)
      '
    />
    """
  end
end
