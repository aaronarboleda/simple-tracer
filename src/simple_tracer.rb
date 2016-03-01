require_relative 'vector'
require_relative 'ray'
require_relative 'scene'
require_relative 'light'
require_relative 'raytrace_tree'
require 'pry'

class SimpleTracer
  MAX_RAYTRACE_DEPTH = 1
  DEFAULT_BACKGROUND_COLOR = [0.1, 0.2, 0.2]

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
      #@pixel_buffer[num_pixel_y][num_pixel_x] = DEFAULT_BACKGROUND_COLOR
      @pixel_buffer[num_pixel_y][num_pixel_x] = [0.0, 0.0, 0.0]
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
        intersection_point = ray.intersection_point
      end
    end

    if intersected_object
      light_value = light_contribution_from(intersected_object, intersection_point, ray.direction_uvec)
      raytrace_tree.light_value = light_value

      # reflect/refract up to allowed depth
      if depth < MAX_RAYTRACE_DEPTH

        # reflection ray
        # R = u - (2u * N) * N
        reflection_origin = intersection_point
        surface_normal = intersected_object.normal(intersection_point)
        reflection_uvec =
          ray.direction_uvec - surface_normal.scale(
              ((ray.direction_uvec.scale(2.0)) * surface_normal)).normalize
        reflection_ray = Ray.new(intersection_point, reflection_uvec)

        raytrace_tree.reflect_node = RaytraceTree.new
        raytrace_tree.reflect_node.distance_from_parent = intersection_distance # TODO: is this a bug

        generate_ray(reflection_ray, raytrace_tree.reflect_node, depth + 1)

        # refraction ray
        if intersected_object.transparent && false
          # figure out angle of refraction via snell's law
          begin
            angle_of_incidence =
              Math.acos(ray.direction_uvec.reverse * surface_normal)

          index_of_refraction_incident = 1.0 # air
          index_of_refraction_material = 1.52 # ordinary crown glass
          refraction_index_coefficient = index_of_refraction_incident / index_of_refraction_material

          angle_of_refraction =
            Math.acos(Math.sqrt(1 - (((refraction_index_coefficient) ** 2) *
              (1 - (Math.cos(angle_of_incidence) ** 2)))))

          refraction_uvec = (ray.direction_uvec.scale(refraction_index_coefficient) -
            surface_normal.scale((Math.cos(angle_of_refraction) - (refraction_index_coefficient * Math.cos(angle_of_incidence))))).normalize

          # TODO: account for hitting backside of clear sphere
          refraction_ray = Ray.new(intersection_point, refraction_uvec)

          raytrace_tree.refract_node = RaytraceTree.new
          raytrace_tree.refract_node.distance_from_parent = intersection_distance

          generate_ray(refraction_ray, raytrace_tree.refract_node, depth + 1)
          rescue StandardError => e
            puts e.backtrace
          end
        end
      end
    end
  end

  def light_contribution_from(intersected_object, intersection_point, incoming_ray_direction_uvec)
    light_source_contributions = []
    @scene.light_sources.each do |light_source|
      to_light_uvec = (light_source.pos - intersection_point).normalize
      shadow_ray = Ray.new(intersection_point, to_light_uvec)
      is_shadowed = @scene.objects.detect do |obj|
        obj != intersected_object && obj.intersects?(shadow_ray)
      end

      unless is_shadowed

        distance_to_light = (light_source.pos - intersection_point).length
        attenuation = Light.attenuate(distance_to_light)

        light_source_contrib = []
        light_source.rgb.length.times do |index|
          light_rgb = light_source.rgb[index]

          # diffuse
          diffuse_rgb = intersected_object.rgb[index]
          if intersected_object.reflectivity
            diffuse_reflectivity = intersected_object.reflectivity
          else
            diffuse_reflectivity = 1.0
          end
          diffuse_incidence = intersected_object.normal(intersection_point) * to_light_uvec
          diffuse_contrib = light_rgb * diffuse_rgb * diffuse_reflectivity * diffuse_incidence

          # specular
          specular_rgb = 1.0
          specular_reflectivity = 1.0
          specular_exponent = 128.0

          halfway_uvec = (to_light_uvec - incoming_ray_direction_uvec).normalize
          specular_incidence = (halfway_uvec * intersected_object.normal(intersection_point)) ** specular_exponent

          specular_contrib = light_rgb * specular_rgb * specular_reflectivity * specular_incidence

          # total
          light_source_contrib << (diffuse_contrib + specular_contrib) * attenuation
        end

        light_source_contributions << light_source_contrib
      end
    end

    light_source_contributions.reduce([0.0, 0.0, 0.0]) do |memo, contrib|
      [memo[0] + contrib[0], memo[1] + contrib[1], memo[2] + contrib[2]]
    end
  end
end
