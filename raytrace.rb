require 'benchmark'
require 'optparse'

require_relative 'src/scene_parser'
require_relative 'src/simple_tracer'
require_relative 'src/ppm_exporter'

DEFAULT_SCENE_FILENAME = 'scene.json'
DEFAULT_EXPORT_FILENAME = 'scene.ppm'
DISPLAY_RENDER_TIME = true

# Command-line options
options = {}
OptionParser.new do |opts|
  opts.on("-s", "--scene SCENE_FILENAME", String) do |val|
    options[:scene_filename] = val
  end

  opts.on("-e", "--export EXPORT_FILENAME", String) do |val|
    options[:export_filename] = val
  end
end.parse!

# Import scene file
scene_filename = options[:scene_filename] ? options[:scene_filename] : DEFAULT_SCENE_FILENAME
scene_parser = SceneParser.new(scene_filename)
scene = scene_parser.parse

# Render scene to pixel buffer
simple_tracer = SimpleTracer.new(scene)

pixel_buffer = []
render_time = Benchmark.realtime do
  pixel_buffer = simple_tracer.render
end

# Export scene
export_filename = options[:export_filename] ? options[:export_filename] : DEFAULT_EXPORT_FILENAME
ppm_exporter = PpmExporter.new(pixel_buffer, export_filename)
ppm_exporter.export

if DISPLAY_RENDER_TIME
  puts "Render time: #{render_time * 1000} milliseconds."
end
