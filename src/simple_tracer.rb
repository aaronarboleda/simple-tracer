require_relative 'vector'
require_relative 'ray'
require_relative 'sphere'
require_relative 'polygon'

class SimpleTracer
  attr_reader :pixel_buffer

  def initialize
    setup_projection
    setup_scene
  end

  def render
    render_scene
  end

  private

  def setup_projection
    @screen_width_in_pixels = 640
    @screen_height_in_pixels = 360

    @screen_width_in_world_units = 16.0
    @screen_height_in_world_units = 9.0

    @projection_ray_origin = Vector.new(0, 0, 12)
  end

  def setup_scene
    @scene = []
    #@scene << Sphere.new(Vector.new(0, 0, -8), 5)
    @scene << Polygon.new(
      [
        Vector.new(-5, -5, -8),
        Vector.new(5, -5, -8),
        Vector.new(5, 5, -8),
        Vector.new(-5, 5, -8),
      ]
    )
    @scene << Polygon.new(
      [
        Vector.new(-10, -5, 10),
        Vector.new(10, -5, 10),
        Vector.new(10, -5, -10),
        Vector.new(-10, -5, -10),
      ]
    )
  end

  def render_scene
    @pixel_buffer = []
    @screen_height_in_pixels.times do |num_pixel_y|
      @pixel_buffer[num_pixel_y] = []
      screen_intersect_y = (@screen_height_in_world_units / @screen_height_in_pixels * -num_pixel_y) + (@screen_height_in_world_units / 2)
      @screen_width_in_pixels.times do |num_pixel_x|
        screen_intersect_x = (@screen_width_in_world_units / @screen_width_in_pixels * num_pixel_x) - (@screen_width_in_world_units / 2)

        # shoot a ray through the center of the pixel[num_pixel_y][num_pixel_x]
        # TODO: shoot through the middle instead of the corners
        screen_intersect_pos = Vector.new(screen_intersect_x, screen_intersect_y, 0)
        ray_to_screen_intersect_uvec = (screen_intersect_pos - @projection_ray_origin).normalize

        ray = Ray.new(@projection_ray_origin, ray_to_screen_intersect_uvec)

        calc_pixel_value(num_pixel_y, num_pixel_x, ray)
      end
    end
  end

  def calc_pixel_value(num_pixel_y, num_pixel_x, ray)
    @scene.each do |obj|
      if obj.intersects?(ray)
        @pixel_buffer[num_pixel_y][num_pixel_x] = [0, 255, 0]
      else
        @pixel_buffer[num_pixel_y][num_pixel_x] = [0, 0, 0]
      end
    end
  end
end
