class Ray
  attr_reader :origin_pos, :direction_uvec
  attr_accessor :intersection_distance #TODO move out of Ray

  def initialize(origin_pos, direction_uvec)
    @origin_pos = origin_pos
    @direction_uvec = direction_uvec
  end

  def project(distance)
    @origin_pos + @direction_uvec.scale(distance)
  end
end
