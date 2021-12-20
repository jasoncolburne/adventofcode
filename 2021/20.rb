#!/usr/bin/env ruby

require 'set'
require 'rubygems'
require 'bundler/setup'
require 'jason/math'

require './screen'

data = <<EOT
..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..##
#..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###
.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#.
.#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#.....
.#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#..
...####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.....
..##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

#..#.
#....
##..#
..#..
..###
EOT

data = File.read(ARGV[0]).chomp
lines = data.chomp.split("\n")

parsing_algorithm = true
algorithm_string = ''
algorithm = []
pre_image_string = ''
lines.each do |line|
  if parsing_algorithm
    if line.empty?
      algorithm = algorithm_string.chars.map { |char| char == '#' ? true : false }
      parsing_algorithm = false
      next
    end
    algorithm_string += line
  else
    pre_image_string += "#{line}\n"
  end
end

@grid = [[-1, -1], [0, -1], [1, -1], [-1, 0], [0, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]
def relevant_cells(x, y)
  @grid.map { |dx, dy| [x + dx, y + dy] }
end

original = Screen.new
original.fill_from_text(pre_image_string)

def enhance_image(original, destination, algorithm, border_character = '.')
  original.add_border(border_character)

  ymin = original.y_min
  ymax = original.y_max
  xmin = original.x_min
  xmax = original.x_max

  original.add_border(border_character)

  (ymin..ymax).each do |y|
    (xmin..xmax).each do |x|
      index = relevant_cells(x, y).map { |coords| '.#'.index(original.display_buffer[coords]).to_s }.join.to_i(2)
      destination[[x, y]] = (algorithm[index] ? '#' : '.')
    end
  end
end

background = '#'
50.times do |n|
  background = if algorithm.first
                 background == '.' ? '#' : '.'
               else
                 '.'
               end

  buffer = Screen.new
  enhance_image(original, buffer, algorithm, background)
  original = buffer

  pp original.find_matches(/#/).count if n == 1
end

pp original.find_matches(/#/).count
