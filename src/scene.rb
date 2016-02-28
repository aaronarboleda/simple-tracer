require_relative 'sphere'
require_relative 'polygon'
require_relative 'color'
require_relative 'light_source'

class Scene
  attr_reader :objects, :light_sources

  def initialize
    @objects = []
    @light_sources = []
  end

  def add_light_source(pos, color)
    @light_sources << LightSource.new(pos, color)
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

    hw = width / 2.0
    hh = height / 2.0
    hd = depth / 2.0

    # front/back
    faces << front_face = [
      Vector.new(-hw, -hh, hd),
      Vector.new(hw, -hh, hd),
      Vector.new(hw, hh, hd),
      Vector.new(-hw, hh, hd),
    ]

    faces << front_face.reverse.map do |vertex|
      Vector.new(vertex.x, vertex.y, -hd)
    end

    # left/right
    faces << left_face = [
      Vector.new(-hw, -hh, -hd),
      Vector.new(-hw, -hh, hd),
      Vector.new(-hw, hh, hd),
      Vector.new(-hw, hh, -hd),
    ]

    faces << left_face.reverse.map do |vertex|
      Vector.new(hw, vertex.y, vertex.z)
    end

    # top/bottom
    faces << top_face = [
      Vector.new(-hw, hh, hd),
      Vector.new(hw, hh, hd),
      Vector.new(hw, hh, -hd),
      Vector.new(-hw, hh, -hd),
    ]

    faces << top_face.reverse.map do |vertex|
      Vector.new(vertex.x, -hh, vertex.z)
    end

    faces.each do |face|
      # translate by pos
      face.map! do |vertex|
        vertex + pos
      end

      add_polygon(face)
    end
  end

  private

  def add_object(obj)
    @objects << obj
  end
end
