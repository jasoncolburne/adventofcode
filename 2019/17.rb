#!env ruby

require 'pp'
require './computer'
require './screen'

program = eval("[" + File.read(ARGV[0]) + "]")
computer = Computer.new
screen = Screen.new
computer.load_program('Main', program, [])
computer.execute_until_all_contexts_are_done

def adjacent_cells(position)
  x = position[0]
  y = position[1]
  [[x, y + 1], [x, y - 1], [x + 1, y], [x - 1, y], [x, y]]
end

outputs = computer.find_context('Main').outputs

x = 0
y = 0
while (value = outputs.shift)
  if value == 10
    y += 1
    x = 0
  else
    screen[[x, y]] = value.chr
    x += 1
  end
end

scaffolding = screen.get_coordinates('#')
intersections = []
scaffolding.each do |coordinates|
  cells = adjacent_cells(coordinates)
  intersections << coordinates if cells.all? { |cell| scaffolding.include?(cell) }
end

puts intersections.map { |a, b| a * b }.inject(&:+)

# solved by hand

instructions = ['A', 'B', 'A', 'C', 'B', 'A', 'C', 'A', 'C', 'B']

a = ['L', 12, 'L', 8, 'L', 8]
b = ['L', 12, 'R', 4, 'L', 12, 'R', 6]
c = ['R', 4, 'L', 12, 'L', 12, 'R', 6]

input = (instructions.join(',') + "\n").split('').map(&:ord) +
        (a.join(',') + "\n").split('').map(&:ord) +
        (b.join(',') + "\n").split('').map(&:ord) +
        (c.join(',') + "\n").split('').map(&:ord) +
        ['n', "\n"].map(&:ord)

program = eval("[" + File.read(ARGV[0]) + "]")
program[0] = 2
computer = Computer.new
screen = Screen.new
computer.load_program('Main', program, input)
computer.execute_until_all_contexts_are_done
pp computer.find_context('Main').outputs.last