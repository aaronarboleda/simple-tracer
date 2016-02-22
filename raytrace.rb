require_relative 'src/simple_tracer'
require_relative 'src/ppm_exporter'

EXPORT_FILENAME = 'test.ppm'

simple_tracer = SimpleTracer.new
ppm_exporter = PpmExporter.new(simple_tracer.pixel_buffer, EXPORT_FILENAME)
ppm_exporter.export
