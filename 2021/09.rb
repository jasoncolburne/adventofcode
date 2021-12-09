#!/usr/bin/env ruby

require './screen'

data = <<EOT
2199943210
3987894921
9856789892
8767896789
9899965678
EOT

data = File.read(ARGV[0])

input = data.chomp.split("\n")

screen = Screen.new

input.each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    screen[[x, y]] = char.to_i
  end
end

# this all performs pretty poorly
pp screen.minimums.values.map { |n| n + 1 }.sum

pp screen.basins.sort_by { |basin| -basin.count }.first(3).map(&:count).inject(&:*)