require_relative 'color'

class SceneObject
  attr_accessor :rgb, :reflectivity, :transparent

  def initialize
    @rgb = Color::WHITE
  end

  def intersects?(ray)
    false
  end

  def normal(pos_on_obj)
    nil
  end
end
