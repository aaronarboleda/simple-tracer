class Scene
  attr_reader :objects, :light_sources

  def initialize
    @objects = []
    @light_sources = []
  end

  def add_object(obj)
    @objects << obj
  end

  def add_light_source(light_source)
    @light_source << light_source
  end
end
