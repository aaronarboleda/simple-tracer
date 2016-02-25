require_relative 'scene_object'

class Polygon < SceneObject
  def initialize(vertices)
    @vertices = vertices
    @normal = calc_normal
  end

  def intersects?(ray)
    has_intersection = false

    if ray.direction_uvec * @normal < 0

      # ray intersects plane specified by polygon
      # now get distance to intersection point

      # N dot P = -D
      plane_coefficient_d = -(@normal * @vertices[0])

      intersection_distance =
        -(plane_coefficient_d + (@normal * ray.origin_pos)) /
        (@normal * ray.direction_uvec)

      # project ray to get intersection point on plane
      intersection_point = ray.project(intersection_distance)

      # finally, do inside-outside test to check if intersection on plane is within polygon
      # intersection occurs within polygon if it happens to the left of all line segments
      is_inside_polygon = true
      @vertices.each_with_index do |current_vertex, index|
        next_vertex = (index + 1 < @vertices.count) ? @vertices[index + 1] : @vertices[0]

        facing_vector = @normal.cross(next_vertex - current_vertex)
        if facing_vector * (intersection_point - current_vertex) <= 0
          is_inside_polygon = false
          break
        end
      end

      if is_inside_polygon
        has_intersection = true
        ray.intersection_distance = intersection_distance
        ray.intersection_point = intersection_point
      end
    end

    has_intersection
  end

  def normal(pos_on_object)
    @normal
  end

  private

  def calc_normal
    # assume polygon specified by at least three vertices given in counter-clockwise order
    first_vector = @vertices[1] - @vertices[0]
    second_vector = @vertices[2] - @vertices[0]

    first_vector.cross(second_vector).normalize
  end
end
