require 'json'

require_relative 'scene'
require_relative 'vector'

class SceneParser
  def initialize(filename)
    @filename = filename
  end

  def parse
    scene = Scene.new

    file = open(@filename)
    json = JSON.parse(file.read)

    json["light_sources"].each do |json_light_source|
      pos = array_to_vector(json_light_source["pos"])
      rgb = json_light_source["rgb"]

      scene.add_light_source(pos, rgb)
    end

    json["scene_objects"].each do |json_object|
      scene_object = nil

      break if json_object["name"].start_with?("xxx")

      if json_object["type"] == "sphere"
        pos = array_to_vector(json_object["pos"])
        radius = json_object["radius"]
        rgb = json_object["rgb"]

        scene_object = Scene.create_sphere(pos, radius)
        scene_object.rgb = rgb
        scene.add_object(scene_object)
      end

      if json_object["type"] == "polygon"
        vertices = json_object["vertices"].map! do |json_vertex|
          array_to_vector(json_vertex)
        end
        rgb = json_object["rgb"]

        scene_object = Scene.create_polygon(vertices)
        scene_object.rgb = rgb
        scene.add_object(scene_object)
      end

      if json_object["type"] == "cube"
        pos = array_to_vector(json_object["pos"])
        length = json_object["length"]
        rgb = json_object["rgb"]

        faces = Scene.create_cube(pos, length)
        faces.each do |face|
          scene_object = Scene.create_polygon(face)
          scene_object.rgb = rgb
          scene.add_object(scene_object)
        end
      end
    end

    scene
  end

  private

  def array_to_vector(array)
    Vector.new(array[0], array[1], array[2])
  end
end
