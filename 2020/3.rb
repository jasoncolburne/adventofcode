#!env ruby

require 'pp'
require './screen'

data = <<EOT
..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#
EOT

data = File.read(ARGV[0])

screen = Screen.new
screen.fill_from_text(data)

def count_trees(screen, delta)
  width = screen.x_values.max + 1  # this doesn't need to be done every time but it makes the code clean
  height = screen.y_values.max + 1

  x = 0
  y = 0
  trees = 0
  while y < height
    trees += 1 if screen[[x, y]] == '#'
    x = (x + delta[0]) % width
    y += delta[1]
  end
  trees
end

puts count_trees(screen, [3, 1])

deltas = [
  [1, 1],
  [3, 1],
  [5, 1],
  [7, 1],
  [1, 2]
]

puts deltas.map { |delta| count_trees(screen, delta) }.inject(&:*)
