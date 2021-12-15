class Screen
  attr_reader :display_buffer

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

  def fill_from_text_as_integers(text)
    inputs = text.split('')
    x = 0
    y = 0
    while (value = inputs.shift)
      if value.chr == "\n"
        y += 1
        x = 0
      else
        @display_buffer[[x, y]] = value.to_i
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

  def x_min
    x_values.min
  end

  def x_max
    x_values.max
  end

  def y_min
    y_values.min
  end

  def y_max
    y_values.max
  end

  def bottom_right_neighbours(coordinates)
    coordinate_set = [
      [coordinates[0] + 1, coordinates[1]],
      [coordinates[0], coordinates[1] + 1],
    ]

    @display_buffer.select { |k, v| coordinate_set.include?(k) }
  end

  def aoc_five_by_five!
    new_buffer = @display_buffer.dup
    width = x_max + 1
    height = y_max + 1

    @display_buffer.each_pair do |key, value|
      value = value % 9 + 1
      new_buffer[[key[0] + width , key[1]]] = value
      new_buffer[[key[0], key[1] + height]] = value

      value = value % 9 + 1
      new_buffer[[key[0] + width * 2 , key[1]]] = value
      new_buffer[[key[0], key[1] + height * 2]] = value
      new_buffer[[key[0] + width, key[1] + height]] = value

      value = value % 9 + 1
      new_buffer[[key[0] + width * 3 , key[1]]] = value
      new_buffer[[key[0], key[1] + height * 3]] = value
      new_buffer[[key[0] + width * 2, key[1] + height]] = value
      new_buffer[[key[0] + width, key[1] + height * 2]] = value

      value = value % 9 + 1
      new_buffer[[key[0] + width * 4 , key[1]]] = value
      new_buffer[[key[0], key[1] + height * 4]] = value
      new_buffer[[key[0] + width * 2, key[1] + height * 2]] = value
      new_buffer[[key[0] + width, key[1] + height * 3]] = value
      new_buffer[[key[0] + width * 3, key[1] + height]] = value

      value = value % 9 + 1
      new_buffer[[key[0] + width * 4, key[1] + height]] = value
      new_buffer[[key[0] + width, key[1] + height * 4]] = value
      new_buffer[[key[0] + width * 3, key[1] + height * 2]] = value
      new_buffer[[key[0] + width * 2, key[1] + height * 3]] = value

      value = value % 9 + 1
      new_buffer[[key[0] + width * 4 , key[1] + height * 2]] = value
      new_buffer[[key[0] + width * 2, key[1] + height * 4]] = value
      new_buffer[[key[0] + width * 3, key[1] + height * 3]] = value

      value = value % 9 + 1
      new_buffer[[key[0] + width * 4, key[1] + height * 3]] = value
      new_buffer[[key[0] + width * 3, key[1] + height * 4]] = value

      value = value % 9 + 1
      new_buffer[[key[0] + width * 4, key[1] + height * 4]] = value
    end

    @display_buffer = new_buffer
  end

  def neighbours(coordinates)
    coordinate_set = [
      [coordinates[0] - 1, coordinates[1]],
      [coordinates[0], coordinates[1] - 1],
      [coordinates[0] + 1, coordinates[1]],
      [coordinates[0], coordinates[1] + 1],
    ]

    @display_buffer.select { |k, v| coordinate_set.include?(k) }
  end

  def minimums
    @minimums ||= @display_buffer.select { |k, v| neighbours(k).values.all? { |neighbour| neighbour > v } }
  end

  def basins
    minimums.map do |k, v|
      result = { k => v }

      coords_to_search = [k]

      while coords_to_search.count > 0
        coordinates = coords_to_search.pop
        neighbours(coordinates).each_pair do |k, v|
          if v != 9 and !result.keys.include?(k)
            result[k] = v
            coords_to_search << k
          end
        end
      end

      result
    end
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

  def edges
    top = @display_buffer.select { |k, v| k[1] == 0 }.keys.map { |cell| @display_buffer[cell] }
    left = @display_buffer.select { |k, v| k[0] == 0 }.keys.map { |cell| @display_buffer[cell] }
    bottom = @display_buffer.select { |k, v| k[1] == left.count - 1 }.keys.map { |cell| @display_buffer[cell] }
    right = @display_buffer.select { |k, v| k[0] == top.count - 1 }.keys.map { |cell| @display_buffer[cell] }

    [top, right, bottom, left]
  end

  def rotate!
    new_buffer = {}
    x_max = @display_buffer.keys.map { |cell| cell[0] }.max
    y_max = @display_buffer.keys.map { |cell| cell[1] }.max

    (0..y_max).each do |y|
      (0..x_max).each do |x|
        new_buffer[[x, y]] = @display_buffer[[y_max - y, x]]
      end
    end

    @display_buffer = new_buffer
  end

  def flip!
    new_buffer = {}
    x_max = @display_buffer.keys.map { |cell| cell[0] }.max
    y_max = @display_buffer.keys.map { |cell| cell[1] }.max

    (0..y_max).each do |y|
      (0..x_max).each do |x|
        new_buffer[[x, y]] = @display_buffer[[x, y_max - y]]
      end
    end

    @display_buffer = new_buffer
  end

  def flop!
    new_buffer = {}
    x_max = @display_buffer.keys.map { |cell| cell[0] }.max
    y_max = @display_buffer.keys.map { |cell| cell[1] }.max

    (0..y_max).each do |y|
      (0..x_max).each do |x|
        new_buffer[[x, y]] = @display_buffer[[x_max - x, y]]
      end
    end

    @display_buffer = new_buffer
  end

  def fold_vertical!(position)
    new_buffer = {}

    x_max = x_values.max
    y_max = y_values.max

    (0..y_max).each do |y|
      (0..(position - 1)).each do |x|
        new_buffer[[x, y]] = @display_buffer[[x, y]] unless @display_buffer[[x, y]].nil?
      end
    end

    (0..y_max).each do |y|
      ((position + 1)..x_max).each do |x|
        new_buffer[[position - (x - position), y]] = @display_buffer[[x, y]] unless @display_buffer[[x, y]].nil?
      end
    end

    @display_buffer = new_buffer
  end

  def fold_horizontal!(position)
    new_buffer = {}

    x_max = x_values.max
    y_max = y_values.max

    (0..(position - 1)).each do |y|
      (0..x_max).each do |x|
        new_buffer[[x, y]] = @display_buffer[[x, y]] unless @display_buffer[[x, y]].nil?
      end
    end

    ((position + 1)..y_max).each do |y|
      (0..x_max).each do |x|
        new_buffer[[x, position - (y - position)]] = @display_buffer[[x, y]] unless @display_buffer[[x, y]].nil?
      end
    end

    @display_buffer = new_buffer
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