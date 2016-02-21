class PpmExporter
  MAGIC_NUMBER = 'P3'
  MAX_COLOR = 255

  EOL = "\n"
  SEP = "\t"

  attr_reader :pixel_buffer, :width, :height, :filename

  def initialize(pixel_buffer, filename)
    @pixel_buffer = pixel_buffer
    @width = pixel_buffer[0].count
    @height = pixel_buffer.count
    @filename = filename
  end

  def export
    image_file = open(@filename, 'w')

    # Write header
    image_file.write(MAGIC_NUMBER + EOL)
    image_file.write('# Insert snarky comment here' + EOL)
    image_file.write("#{@width} #{@height}" + EOL)
    image_file.write(MAX_COLOR.to_s + EOL)

    # Write pixel values
    @height.times do |y|
      @width.times do |x|
        pixel_rgb = @pixel_buffer[y][x]
        image_file.write("#{pixel_rgb[0]}#{SEP}#{pixel_rgb[1]}#{SEP}#{pixel_rgb[2]}#{SEP}")
      end
      image_file.write(EOL)
    end

    image_file.close
  end
end
