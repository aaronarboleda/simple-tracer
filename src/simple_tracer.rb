require_relative 'vector'
require_relative 'ray'
require_relative 'scene'
require_relative 'light'

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
    @scene = Scene.new
    @scene.add_light_source(Vector.new(4, 4, 4), Color::CYAN)
    @scene.add_light_source(Vector.new(-3, 5, 2), [1.0, 0.7, 0.8])
    @scene.add_light_source(Vector.new(15, 4, -5), Color::GREEN)
    #@scene.add_light_source(Vector.new(5, 5, -10), [1.0, 0.7, 0.8])

    # snowman
    @scene.add_sphere(Vector.new(-3, -3, -6), 2)
    @scene.add_sphere(Vector.new(-3, 0.2, -6), 1.5)
    @scene.add_sphere(Vector.new(-3, 2.5, -6), 1)

    #eyes
    @scene.add_sphere(Vector.new(-3.25, 2.55, -5), 0.15)
    @scene.add_sphere(Vector.new(-2.65, 2.55, -5), 0.15)

    #baby snowman
    @scene.add_sphere(Vector.new(1, -4.2, -5.5), 0.8)
    @scene.add_sphere(Vector.new(1, -3.15, -5.5), 0.6)
    @scene.add_sphere(Vector.new(1, -2.20, -5.5), 0.4)

    # floor
    @scene.add_polygon(
      [
        Vector.new(-10, -5, 10),
        Vector.new(10, -5, 10),
        Vector.new(10, -5, -20),
        Vector.new(-10, -5, -20),
      ]
    )

    # cube
    @scene.add_cube(Vector.new(5.0, -3.5, -7.5), 3.0)

=begin
    #tree bottom
    @scene.add_object(Polygon.new(
      [
        Vector.new(3, -4, -7.5),
        Vector.new(7, -4, -7.5),
        Vector.new(5, -1, -7.5)
      ]
    ))

    #tree center
    @scene.add_object(Polygon.new(
      [
        Vector.new(3.5, -2.5, -7.5),
        Vector.new(6.5, -2.5, -7.5),
        Vector.new(5, 0, -7.5)
      ]
    ))

    #tree top
    @scene.add_object(Polygon.new(
      [
        Vector.new(4, -1, -7.5),
        Vector.new(6, -1, -7.5),
        Vector.new(5, 0.3, -7.5)
      ]
    ))
=end

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
    intersected_object = nil
    intersection_distance = Float::MAX
    intersection_point = nil

    @scene.objects.each do |obj|
      if obj.intersects?(ray) && ray.intersection_distance < intersection_distance
        intersected_object = obj
        intersection_distance = ray.intersection_distance
        intersection_point =  ray.intersection_point
      end
    end

    if intersected_object
      # check for contribution from each light source
      light_source_contributions = []
      @scene.light_sources.each do |light_source|
        to_light_vector = (light_source.pos - intersection_point).normalize
        shadow_ray = Ray.new(intersection_point, to_light_vector)
        is_shadowed = @scene.objects.detect do |obj|
          obj != intersected_object && obj.intersects?(shadow_ray)
        end

        unless is_shadowed
          # diffuse contribution is proportional to N * L
          diffuse_incidence = intersected_object.normal(intersection_point) * to_light_vector

          distance_to_light = (light_source.pos - intersection_point).length
          attenuation = Light.attenuate(distance_to_light)

          light_source_contributions << light_source.color.map do |rgb|
            rgb * diffuse_incidence * attenuation
          end
        end

        @pixel_buffer[num_pixel_y][num_pixel_x] =
          light_source_contributions.reduce([0.0, 0.0, 0.0]) do |memo, contrib|
            [memo[0] + contrib[0], memo[1] + contrib[1], memo[2] + contrib[2]]
          end
      end
    else
      @pixel_buffer[num_pixel_y][num_pixel_x] = [0.2, 0.2, 0.2]
    end
  end
end
