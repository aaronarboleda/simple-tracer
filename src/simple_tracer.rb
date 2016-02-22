require_relative 'vector'
require_relative 'ray'
require_relative 'sphere'

class SimpleTracer
  attr_reader :pixel_buffer

  def initialize
    setup_projection
    setup_scene
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
    @scene << Sphere.new(Vector.new(0, 0, -8), 5)
  end

  def render_scene
    @pixel_buffer = []
    @screen_height_in_pixels.times do |y|
      @pixel_buffer[y] = []
      pixel_y = (@screen_height_in_world_units / @screen_height_in_pixels * -y) + (@screen_height_in_world_units / 2)
      @screen_width_in_pixels.times do |x|
        # shoot a ray through the center of the pixel[y][x]
        # TODO: shoot through the middle instead of the corners
        pixel_x = (@screen_width_in_world_units / @screen_width_in_pixels * x) - (@screen_width_in_world_units / 2)

        pixel_pos = Vector.new(pixel_x, pixel_y, 0)
        ray_to_pixel_uvec = (pixel_pos - @projection_ray_origin).normalize

        ray = Ray.new(@projection_ray_origin, ray_to_pixel_uvec)

        # debug
        @scene.each do |obj|
          if obj.intersects?(ray)
            @pixel_buffer[y][x] = [255, 127, 0]
          else
            @pixel_buffer[y][x] = [0, 255, 255]
          end
        end
      end
    end
  end
end
