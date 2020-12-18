#!/usr/bin/env ruby

data = <<EOT
.#.
..#
###
EOT

data = File.read(ARGV[0])

# neighbours_3d = ->(cell) do
#   ((cell[0] - 1)..(cell[0] + 1)).map do |x|
#     ((cell[1] - 1)..(cell[1] + 1)).map do |y|
#       ((cell[2] - 1)..(cell[2] + 1)).map do |z|
#         neighbour = [x, y, z]
#         cell == neighbour ? nil : neighbour
#       end
#     end
#   end.flatten(2).compact
# end

def neighbours(cell, dimensions = nil)
  d = dimensions || cell.count

  string = ""
  if d.zero?
    coordinates = (0..(cell.count - 1)).map { |n| "x#{n}" }.join(", ")
    string += "neighbour = [#{coordinates}]\n"
    string += "neighbour == cell ? nil : neighbour\n"
  else
    string += "((cell[#{d - 1}] - 1)..(cell[#{d - 1}] + 1)).map do |x#{d - 1}|\n"
    string += neighbours(cell, d - 1)
    string += "end\n"
  end

  dimensions == nil ? eval(string.chomp + ".flatten(#{d - 1}).compact\n") : string
end

def evolve(state, n = 6)
  n.times do
    # could use a set here if memory was a concern - not sure if the uniq is overall slower than
    # the set operations would be but it probably is too. this solution still runs in a few seconds
    to_check = state.select { |k, v| v }.keys.map { |cell| neighbours(cell) + [cell] }.flatten(1).uniq
    new_state = {}

    to_check.each do |cell|
      count = neighbours(cell).select { |c| state[c] }.count
      if state[cell]
        new_state[cell] = count == 2 || count == 3 ? true : false
      else
        new_state[cell] = count == 3 ? true : false
      end
    end

    state = new_state
  end

  state
end

lines = data.chomp.split("\n")

state_3d = {}
state_4d = {}

lines.each_with_index do |line, y|
  (0..(line.length - 1)).each do |x|
    state_3d[[x, y, 0]] = line[x] == '#'
    state_4d[[x, y, 0, 0]] = line[x] == '#'
  end
end

puts evolve(state_3d).select { |k, v| v }.count
puts evolve(state_4d).select { |k, v| v }.count
