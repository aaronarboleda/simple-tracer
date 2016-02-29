require_relative 'config'
require_relative 'scene_parser'
require_relative 'vector'
require_relative 'ray'
require_relative 'scene'
require_relative 'light'
require 'pry'

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
    @scene = SceneParser.new('example.json').parse
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
      @pixel_buffer[num_pixel_y][num_pixel_x] = get_light_contribution(intersected_object, intersection_point)
    else
      @pixel_buffer[num_pixel_y][num_pixel_x] = [0.2, 0.2, 0.2]
    end
  end

  def get_light_contribution(intersected_object, intersection_point)
    # check for contribution from each light source
    light_source_contributions = []
    @scene.light_sources.each do |light_source|
      to_light_uvec = (light_source.pos - intersection_point).normalize
      shadow_ray = Ray.new(intersection_point, to_light_uvec)
      is_shadowed = @scene.objects.detect do |obj|
        obj != intersected_object && obj.intersects?(shadow_ray)
      end

      unless is_shadowed
        diffuse_incidence = intersected_object.normal(intersection_point) * to_light_uvec

        distance_to_light = (light_source.pos - intersection_point).length
        attenuation = Light.attenuate(distance_to_light)

        light_source_contrib = []
        light_source.rgb.length.times do |index|

          if Config::LIGHT_SOURCE_RGB_ON
            light_rgb = light_source.rgb[index]
          else
            # white light
            light_rgb = 1.0
          end

          diffuse_rgb = intersected_object.rgb[index]

          light_source_contrib << (light_rgb * diffuse_rgb * diffuse_incidence * attenuation)
        end

        light_source_contributions << light_source_contrib
      end
    end

    light_source_contributions.reduce([0.0, 0.0, 0.0]) do |memo, contrib|
      [memo[0] + contrib[0], memo[1] + contrib[1], memo[2] + contrib[2]]
    end
  end
end
