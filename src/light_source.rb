class LightSource
  attr_reader :pos, :rgb

  def initialize(pos, rgb)
    @pos = pos
    @rgb = rgb
  end
end
