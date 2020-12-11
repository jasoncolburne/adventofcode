#!/usr/bin/env ruby

require './screen'

data = <<EOT
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL
EOT

data = File.read(ARGV[0])

# this could be way faster if i wasn't so committed to using my screen construct
screen = Screen.new
screen.fill_from_text(data)

last_screen = nil

def adjacent_cells(cell)
  x, y = cell
  [[x-1, y-1], [x-1, y], [x-1, y+1],
   [x, y-1], [x, y+1],
   [x+1, y-1], [x+1, y], [x+1, y+1]]
end

def advance_state(screen)
  new_screen = Screen.new
  screen.keys.each do |cell|
    current_value = screen[cell]
    adjacent_values = adjacent_cells(cell).map { |cell| screen[cell] }.compact
    if current_value == 'L' && adjacent_values.select { |value| value == '#' }.count.zero?
      new_screen[cell] = '#'
    elsif current_value == '#' && adjacent_values.select { |value| value == '#' }.count >= 4
      new_screen[cell] = 'L'
    else
      new_screen[cell] = screen[cell]
    end
  end
  new_screen
end

until last_screen && last_screen.to_s == screen.to_s do
  last_screen = screen
  screen = advance_state(last_screen)
end

puts screen.get_coordinates('#').count

screen = Screen.new
screen.fill_from_text(data)

def can_see_occupied?(screen, cell, direction)
  next_cell = nil
  case direction
  when :n
    next_cell = [cell[0], cell[1]-1]
  when :ne
    next_cell = [cell[0]+1, cell[1]-1]
  when :e
    next_cell = [cell[0]+1, cell[1]]
  when :se
    next_cell = [cell[0]+1, cell[1]+1]
  when :s
    next_cell = [cell[0], cell[1]+1]
  when :sw
    next_cell = [cell[0]-1, cell[1]+1]
  when :w
    next_cell = [cell[0]-1, cell[1]]
  when :nw
    next_cell = [cell[0]-1, cell[1]-1]
  end
  next_value = screen[next_cell]
  return 0 if next_value == 'L' || next_value.nil?
  return 1 if next_value == '#'
  can_see_occupied?(screen, next_cell, direction)
end

def count_visible_occupied(screen, cell)
  [:n, :ne, :e, :se, :s, :sw, :w, :nw].map { |direction| can_see_occupied?(screen, cell, direction) }.inject(&:+)  
end

def advance_state(screen)
  new_screen = Screen.new
  screen.keys.each do |cell|
    current_value = screen[cell]
    visible_occupied = count_visible_occupied(screen, cell)
    if current_value == 'L' && visible_occupied.zero?
      new_screen[cell] = '#'
    elsif current_value == '#' && visible_occupied >= 5
      new_screen[cell] = 'L'
    else
      new_screen[cell] = screen[cell]
    end
  end
  new_screen
end

last_screen = nil
until last_screen && last_screen.to_s == screen.to_s do
  last_screen = screen
  screen = advance_state(last_screen)
end

puts screen.get_coordinates('#').count
