require_relative 'scene_object'

class Polygon < SceneObject
  def initialize(vertices)
    @vertices = vertices
    calc_normal
  end

  def intersects?(ray)
    if ray.direction_uvec * @normal < 0

      # ray intersects plane specified by polygon
      # now get distance to intersection point

      # N dot P = -D
      plane_coefficient_d = -(@normal * @vertices[0])

      intersection_distance =
        -(plane_coefficient_d + (@normal * ray.origin_pos)) /
        (@normal * ray.direction_uvec)

      # now plug distance back into ray formula to get intersection point on plane
      intersection_point =
        ray.origin_pos + ray.direction_uvec.scale(intersection_distance)

      # finally, do inside-outside test to check if intersection on plane is within polygon
      v = 0
      is_inside_polygon = true
      while v < @vertices.count do
        first_vertex = @vertices[v]
        second_vertex = (v + 1 == @vertices.count) ? @vertices[0] : @vertices[v + 1]
        facing_vector = @normal.cross(second_vertex - first_vertex)
        if facing_vector * (intersection_point - first_vertex) <= 0
          is_inside_polygon = false
          break
        else
          v += 1
        end
      end
      is_inside_polygon
    else
      false
    end
  end

  private

  def calc_normal
    # assume polygon specified by at least three vertices given in counter-clockwise order
    first_vector = @vertices[1] - @vertices[0]
    second_vector = @vertices[2] - @vertices[0]

    @normal = first_vector.cross(second_vector).normalize
  end
end
