require_relative 'config'
require_relative 'vector'
require_relative 'ray'
require_relative 'scene'
require_relative 'light'
require_relative 'raytrace_tree'

class SimpleTracer
  def initialize(scene)
    @scene = scene
    setup_projection
  end

  def render
    render_scene

    @pixel_buffer
  end

  private

  def setup_projection
    @screen_width_in_pixels = 640
    @screen_height_in_pixels = 360

    @screen_width_in_world_units = 16.0
    @screen_height_in_world_units = 9.0

    @projection_ray_origin = Vector.new(0, 0, 12)
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
    raytrace_tree = RaytraceTree.new

    # initial ray starts off with tree of depth 0
    generate_ray(ray, raytrace_tree, 0)

    if raytrace_tree.light_value
      @pixel_buffer[num_pixel_y][num_pixel_x] = RaytraceTree.traverse(raytrace_tree)
    else
      @pixel_buffer[num_pixel_y][num_pixel_x] = [0.1, 0.2, 0.2]
    end
  end

  def generate_ray(ray, raytrace_tree, depth)
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
      light_value = light_contribution_from(intersected_object, intersection_point)
      raytrace_tree.light_value = light_value

      # reflect/refract up to allowed depth
      if depth < 1

        # R = u - (2u * N) * N
        reflection_origin = intersection_point
        surface_normal = intersected_object.normal(intersection_point)
        reflection_uvec =
          ray.direction_uvec -
          surface_normal.scale(
            ((ray.direction_uvec.scale(2.0)) * surface_normal)).normalize
        reflection_ray = Ray.new(intersection_point, reflection_uvec)

        raytrace_tree.reflect_node = RaytraceTree.new

        generate_ray(reflection_ray, raytrace_tree.reflect_node, depth + 1)
      end
    end
  end

  def light_contribution_from(intersected_object, intersection_point)
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

          light_rgb = light_source.rgb[index]

          diffuse_rgb = intersected_object.rgb[index]
          if (intersected_object.reflectivity)
            diffuse_reflectivity = intersected_object.reflectivity
          else
            diffuse_reflectivity = 0.5
          end

          light_source_contrib << (light_rgb * diffuse_rgb * diffuse_reflectivity * diffuse_incidence * attenuation)
        end

        light_source_contributions << light_source_contrib
      end
    end

    light_source_contributions.reduce([0.0, 0.0, 0.0]) do |memo, contrib|
      [memo[0] + contrib[0], memo[1] + contrib[1], memo[2] + contrib[2]]
    end
  end
end
