require 'benchmark'

require_relative 'src/simple_tracer'
require_relative 'src/ppm_exporter'

CONFIG_EXPORT_FILENAME = 'test.ppm'
CONFIG_DISPLAY_RENDER_TIME = true

simple_tracer = SimpleTracer.new

render_time = Benchmark.realtime do
  simple_tracer.render
end

ppm_exporter = PpmExporter.new(simple_tracer.pixel_buffer, CONFIG_EXPORT_FILENAME)
ppm_exporter.export

if CONFIG_DISPLAY_RENDER_TIME
  puts "Render time: #{render_time * 1000} milliseconds."
end
