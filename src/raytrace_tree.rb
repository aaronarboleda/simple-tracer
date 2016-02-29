class RaytraceTree
  attr_accessor :light_value
  attr_accessor :reflect_node, :refract_node

  def initialize
    @light_value = nil
    @reflect_node = nil
    @refract_node = nil
  end

  def self.traverse(tree)
    light_value = tree.light_value
    if tree.reflect_node
      reflect_value = traverse(tree.reflect_node)
      if reflect_value
        light_value.length.times do |index|
          light_value[index] += reflect_value[index]
        end
      end
    end

    if tree.refract_node
      refract_value = traverse(tree.refract_node)
      if refract_value
        light_value.length.times do |index|
          light_value[index] += refract_value[index]
        end
      end
    end

    light_value
  end
end
