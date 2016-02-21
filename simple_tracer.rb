class SimpleTracer
  attr_accessor :num_pixels_x, :num_pixels_y, :pixel_buffer
  attr_reader :scene

  def initialize
    @num_pixels_x = 640
    @num_pixels_y = 360

    @scene = []
    setup_scene

    # move these values somewhere else
    projection_origin = Vector.new(0, 0, 12)
    screen_area_width = 16.0
    screen_area_height = 9.0

    #fill pixel buffer with crap
    @pixel_buffer = []
    @num_pixels_y.times do |y|
      @pixel_buffer[y] = []
      pixel_y = (screen_area_height / @num_pixels_y * -y) + (screen_area_height / 2)
      @num_pixels_x.times do |x|
        # shoot a ray through the center of the pixel[y][x]
        pixel_x = (screen_area_width / @num_pixels_x * x) - (screen_area_width / 2)

        pixel_pos = Vector.new(pixel_x, pixel_y, 0)
        ray_to_pixel_uvec = (pixel_pos - projection_origin).normalize

        ray = Ray.new(projection_origin, ray_to_pixel_uvec)

        # debug
        @scene.each do |obj|
          if obj.intersects?(ray)
            @pixel_buffer[y][x] = [255, 0, 0]
          else
            @pixel_buffer[y][x] = [255, 255, 255]
          end
        end
      end
    end
  end

  private

  def setup_scene
    @scene << Sphere.new(Vector.new(0, 0, -8), 5)
  end
end
