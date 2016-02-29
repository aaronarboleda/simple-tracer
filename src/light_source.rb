require_relative 'color'

class LightSource
  attr_reader :pos, :rgb

  def initialize(pos, rgb = Color::WHITE)
    @pos = pos
    @rgb = rgb
  end
end
