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

  def display(clear = false)
    output(STDOUT, clear)
  end

  def write(filename)
    file = File.open(filename, "w")
    output(file)
    file.close
  end

  def get_coordinates(value)
    @display_buffer.select { |k, v| v == value }.keys
  end

  def find_matches(expression)
    @display_buffer.select { |k, v| v =~ expression }
  end

  def find_rectangle(w, h, value)
    coordinate_sets = get_coordinates(value)
    coordinate_sets.each do |coordinates|
      x = coordinates[0]
      y = coordinates[1]

      other_corners = [[x + w - 1, y], [x, y + h - 1], [x + w - 1, y + h - 1]]
      return coordinates if other_corners.all? { |corner| @display_buffer[corner] == value }
    end
    nil
  end

  def count_chars_in_last_row(value)
    y = y_values.max
    @display_buffer.select { |k, v| v == value && k[1] == y }.count
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