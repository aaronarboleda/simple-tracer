require_relative 'scene_object'

class Sphere < SceneObject
  def initialize(pos, radius)
    @pos = pos
    @radius = radius
  end

  def intersects?(ray)
    delta_pos = @pos - ray.origin_pos
    u_dot_delta_pos = ray.direction_uvec * delta_pos

    # calculate discriminant
    # if discriminant is negative, there is no intersection
    # if discriminant is positive, intersection happens at the smaller value distance

    delta_pos_length = delta_pos.length # storing so don't have to calculate twice

    discriminant =
      (u_dot_delta_pos * u_dot_delta_pos) -
      (delta_pos_length * delta_pos_length) +
      (@radius * @radius)

    if discriminant < 0
      false
    else
      sqrt_discriminant = Math.sqrt(discriminant)
      intersection_distance = [u_dot_delta_pos + sqrt_discriminant, u_dot_delta_pos - sqrt_discriminant].min
      intersection_point = ray.project(intersection_distance)

      ray.intersection_distance = intersection_distance
      true
    end
  end
end
