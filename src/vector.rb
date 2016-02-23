class Vector
  attr_accessor :x, :y, :z

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end

  def +(obj)
    if obj.is_a?(Vector)
      Vector.new(@x + obj.x, @y + obj.y, @z + obj.z)
    else
      raise_wrong_type_error(__method__.to_s)
    end
  end

  def -(obj)
    if obj.is_a?(Vector)
      Vector.new(@x - obj.x, @y - obj.y, @z - obj.z)
    else
      raise_wrong_type_error(__method__.to_s)
    end
  end

  def *(obj)
    if obj.is_a?(Vector)
      (@x * obj.x) + (@y * obj.y) + (@z * obj.z)
    else
      raise_wrong_type_error(__method__.to_s)
    end
  end

  def cross(obj)
    if obj.is_a?(Vector)
      Vector.new(
        (@y * obj.z) - (@z * obj.y),
        (@z * obj.x) - (@x * obj.z),
        (@x * obj.y) - (@y * obj.x)
      )
    else
      raise_wrong_type_error(__method__.to_s)
    end
  end

  def scale(scalar)
    Vector.new(@x * scalar, @y * scalar, @z * scalar)
  end

  def length
    Math.sqrt(
      (@x * @x) + (@y * @y) + (@z * @z)
    )
  end

  def normalize
    length = self.length
    Vector.new(@x / length, @y / length, @z / length)
  end

  def to_s
    "(#{@x}, #{@y}, #{@z})"
  end

  private

  def raise_wrong_type_error(operation)
    raise "Vector operation '" + operation + "' invoked with non-vector argument"
  end
end
