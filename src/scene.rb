class Scene
  attr_reader :objects, :light_sources

  def initialize
    @objects = []
    @light_sources = []
  end

  def add_sphere(pos, radius)
    add_object(Sphere.new(pos, radius))
  end

  def add_polygon(vertices)
    add_object(Polygon.new(vertices))
  end

  def add_cube(pos, width)
    add_box(pos, width, width, width)
  end

  def add_box(pos, width, height, depth)
    faces = []

    # front/back
    faces << front_face = [
      Vector.new(-width / 2.0, -height / 2.0, depth / 2.0),
      Vector.new(width / 2.0, -height / 2.0, depth / 2.0),
      Vector.new(width / 2.0, height / 2.0, depth / 2.0),
      Vector.new(-width / 2.0, height / 2.0, depth / 2.0),
    ]

    faces << front_face.reverse.map do |vertex|
      Vector.new(vertex.x, vertex.y, -depth / 2.0)
    end

    # left/right
    faces << left_face = [
      Vector.new(-width / 2.0, -height / 2.0, -depth / 2.0),
      Vector.new(-width / 2.0, -height / 2.0, depth / 2.0),
      Vector.new(-width / 2.0, height / 2.0, depth / 2.0),
      Vector.new(-width / 2.0, height / 2.0, -depth / 2.0),
    ]

    faces << left_face.reverse.map do |vertex|
      Vector.new(width / 2.0, vertex.y, vertex.z)
    end

    # top/bottom
    faces << top_face = [
      Vector.new(-width / 2.0, height / 2.0, depth / 2.0),
      Vector.new(width / 2.0, height / 2.0, depth / 2.0),
      Vector.new(width / 2.0, height / 2.0, -depth / 2.0),
      Vector.new(-width / 2.0, height / 2.0, -depth / 2.0),
    ]

    faces << top_face.reverse.map do |vertex|
      Vector.new(vertex.x, -height / 2.0, vertex.z)
    end

    faces.each do |face|
      # translate by pos
      face.map! do |vertex|
        vertex + pos
      end

      add_polygon(face)
    end
  end

  def add_light_source(pos, color)
    @light_sources << LightSource.new(pos, color)
  end

  private

  def add_object(obj)
    @objects << obj
  end
end
