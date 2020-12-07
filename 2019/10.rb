#!/usr/bin/env ruby

require 'pp'

map = <<EOT
.#..#
.....
#####
....#
...##
EOT

map = <<EOT
......#.#.
#..#.#....
..#######.
.#.#.###..
.#..#.....
..#....#.#
#..#....#.
.##.#..###
##...#..#.
.#....####
EOT

map = <<EOT
#.#...#.#.
.###....#.
.#....#...
##.#.#.#.#
....#.#.#.
.##..###.#
..#...##..
..##....##
......#...
.####.###.
EOT

map = <<EOT
.#..#..###
####.###.#
....###.#.
..###.##.#
##.##.#.#.
....###..#
..#.#..#.#
#..#.#.###
.##...##.#
.....#.#..
EOT

map = <<EOT
.#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##
EOT

# map = <<EOT
# .#....#####...#..
# ##...##.#####..##
# ##...#...#.#####.
# ..#.....#...###..
# ..#.#.....#....##
# EOT

map = File.read(ARGV[0])
lines = map.chomp.split("\n")

asteroid_coordinates = []
(0..(lines.length - 1)).each do |y|
  (0..(lines.first.length - 1)).each do |x|
    asteroid_coordinates << [x, y] if lines[y][x] == '#'
  end
end

def angle(origin, asteroid)
  Math.atan2(asteroid[0] - origin[0], asteroid[1] - origin[1])
end

def distance(origin, asteroid)
  ((asteroid[0] - origin[0]) ** 2 + (asteroid[1] - origin[1]) ** 2) ** 0.5
end

def asteroids_by_angle(origin, asteroid_coordinates)
  asteroid_coordinates.reject { |coordinates| coordinates == origin }.map do |coordinates|
    {
      angle: angle(origin, coordinates),
      distance: distance(origin, coordinates),
      coordinates: coordinates
    }
  end.group_by { |data| data[:angle] }.map { |k, v| [k, v.sort_by { |asteroid| asteroid[:distance] }]}.to_h
end

def visible_asteroids(asteroids_by_angle)
  asteroids_by_angle.map { |angle, asteroids| asteroids.first }
end

visible_count_by_coordinates = {}
asteroid_coordinates.each do |coordinates|
  asteroids_by_angle = asteroids_by_angle(coordinates, asteroid_coordinates)
  visible_count_by_coordinates[coordinates] = visible_asteroids(asteroids_by_angle).count
end

base = visible_count_by_coordinates.select { |key, value| value == visible_count_by_coordinates.values.max }.keys.first
puts "From #{base}: #{visible_count_by_coordinates[base]} asteroids visible"

asteroids_by_angle = asteroids_by_angle(base, asteroid_coordinates)

counter = 1
while !asteroids_by_angle.values.all?(&:empty?)
  asteroids_by_angle.keys.sort.reverse.each do |angle|
    unless asteroids_by_angle[angle].empty?
      asteroid = asteroids_by_angle[angle].shift
      if counter == 200
        result = asteroid[:coordinates][0] * 100 + asteroid[:coordinates][1]
        puts "Solution at 200: #{result}"
      end
      counter += 1
    end
  end
end


