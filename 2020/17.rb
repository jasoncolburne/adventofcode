#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'jason/math'

data = <<EOT
.#.
..#
###
EOT

data = File.read(ARGV[0])

def evolve(state, n = 6)
  n.times do
    # could use a set here if memory was a concern - not sure if the uniq is overall slower than
    # the set operations would be but it probably is too. this solution still runs in a few seconds
    to_check = state.select { |k, v| v }.keys.map { |cell| cell.neighbouring_cells + [cell] }.flatten(1).uniq
    new_state = {}

    to_check.each do |cell|
      count = cell.neighbouring_cells.select { |c| state[c] }.count
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
