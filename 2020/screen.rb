class Screen
  def initialize(background: ' ', reverse_y: false)
    @background = background
    @reverse_y = reverse_y
    @display_buffer = {}
  end

  def fill_from_text(text)
    inputs = text.split('')
    x = 0
    y = 0
    while (value = inputs.shift)
      if value.chr == "\n"
        y += 1
        x = 0
      else
        @display_buffer[[x, y]] = value.chr
        x += 1
      end
    end

    self
  end

  def []=(coordinates, value)
    @display_buffer[coordinates] = value
  end

  def [](coordinates)
    @display_buffer[coordinates]
  end

  def write(file = STDOUT, clear = false)
    output(file, clear)
  end

  def to_s
    buffer = StringIO.new
    write(buffer)
    buffer.string
  end

  def get_coordinates(value)
    @display_buffer.select { |k, v| v == value }.keys
  end

  def find_matches(expression)
    @display_buffer.select { |k, v| v =~ expression }
  end

  def dimensions
    x_min = x_values.min
    x_max = x_values.max
    y_min = y_values.min
    y_max = y_values.max

    [x_max - x_min, y_max - y_min]
  end

  def x_values
    @display_buffer.keys.map { |coordinates| coordinates[0] }.uniq
  end

  def y_values
    @display_buffer.keys.map { |coordinates| coordinates[1] }.uniq
  end

  def keys
    @display_buffer.keys
  end

  private

  def output(file, clear = false)    
    x_min = x_values.min
    x_max = x_values.max
    y_min = y_values.min
    y_max = y_values.max
    
    y_range = @reverse_y ? (y_min..y_max).to_a.reverse : (y_min..y_max)

    file.print "\e[H\e[2J" if clear
    y_range.each do |y|
      (x_min..x_max).each do |x|
        file.print @display_buffer[[x, y]] || @background
      end
      file.puts
    end
  end
end