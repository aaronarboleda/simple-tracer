class SceneObject
  attr_accessor :diffuse_rgb

  def intersects?(ray)
    false
  end

  def normal(pos_on_obj)
    nil
  end
end
