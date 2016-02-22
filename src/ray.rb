class Ray
  attr_reader :origin_pos, :direction_uvec

  def initialize(origin_pos, direction_uvec)
    @origin_pos = origin_pos
    @direction_uvec = direction_uvec
  end
end
