#!/usr/bin/env ruby

require 'set'
require 'rubygems'
require 'bundler/setup'
require 'jason/math'

data = <<EOT
5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526
EOT

# data = <<EOT
# 11111
# 19991
# 19191
# 19991
# 11111
# EOT

def get_flashed_coordinates(octopii)
  flashed_coordinates = Set[]

  (0..(octopii.length - 1)).each do |y|
    (0..(octopii.length - 1)).each do |x|
      flashed_coordinates << [x, y] if octopii[y][x] > 9
    end
  end

  flashed_coordinates
end

def step(octopii)
  octopii.map! { |row| row.map { |cell| cell + 1 } }

  flashed_coordinates = Set[]
  while true
    new_flashed_coordinates = get_flashed_coordinates(octopii) - flashed_coordinates
    break if new_flashed_coordinates.empty?

    new_flashed_coordinates.each do |coordinates|
      neighbours = Math.neighbouring_cells(coordinates).to_set
      neighbours.each do |x, y|
        octopii[y][x] += 1 if 0 <= x && octopii.length - 1 >= x && 0 <= y && octopii.length - 1 >= y
      end
    end

    flashed_coordinates |= new_flashed_coordinates
  end

  octopii.map! { |row| row.map { |cell| cell > 9 ? 0 : cell }}

  flashed_coordinates.count
end

def count_flashes(octopii, generations = 100)
  flashes = 0

  generations.times do |generation|
    flashes += step(octopii)
  end

  flashes
end

def find_full_flash(octopii)
  generation = 0

  while true do
    step(octopii)
    generation += 1
    break if octopii.map { |line| line.sum }.sum.zero?
  end

  generation
end

data = File.read(ARGV[0])
input = data.chomp.split("\n")

octopii = input.map { |line| line.chars.map(&:to_i) }
pp count_flashes(octopii)

octopii = input.map { |line| line.chars.map(&:to_i) }
pp find_full_flash(octopii)
