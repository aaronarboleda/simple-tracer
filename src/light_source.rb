class LightSource
  attr_reader :pos, :color

  def initialize(pos, color)
    @pos = pos
    @color = color
  end
end
