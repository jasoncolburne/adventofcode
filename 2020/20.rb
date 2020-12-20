#!/usr/bin/env ruby

require 'set'
require './screen'

data = <<EOT
Tile 2311:
..##.#..#.
##..#.....
#...##..#.
####.#...#
##.##.###.
##...#.###
.#.#.#..##
..#....#..
###...#.#.
..###..###

Tile 1951:
#.##...##.
#.####...#
.....#..##
#...######
.##.#....#
.###.#####
###.##.##.
.###....#.
..#.#..#.#
#...##.#..

Tile 1171:
####...##.
#..##.#..#
##.#..#.#.
.###.####.
..###.####
.##....##.
.#...####.
#.##.####.
####..#...
.....##...

Tile 1427:
###.##.#..
.#..#.##..
.#.##.#..#
#.#.#.##.#
....#...##
...##..##.
...#.#####
.#.####.#.
..#..###.#
..##.#..#.

Tile 1489:
##.#.#....
..##...#..
.##..##...
..#...#...
#####...#.
#..#.#.#.#
...#.#.#..
##.#...##.
..##.##.##
###.##.#..

Tile 2473:
#....####.
#..#.##...
#.##..#...
######.#.#
.#...#.#.#
.#########
.###.#..#.
########.#
##...##.#.
..###.#.#.

Tile 2971:
..#.#....#
#...###...
#.#.###...
##.##..#..
.#####..##
.#..####.#
#..#.#..#.
..####.###
..#.#.###.
...#.#.#.#

Tile 2729:
...#.#.#.#
####.#....
..#.#.....
....#..#.#
.##..##.#.
.#.####...
####.#.#..
##.####...
##..#.##..
#.##...##.

Tile 3079:
#.#.#####.
.#..######
..#.......
######....
####.#..#.
.#...#.##.
#.#####.##
..#.###...
..#.......
..#.###...
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")

tiles = {}

y = nil
screen = nil

lines.each do |line|
  if line =~ /^Tile (\d+):$/
    y = 0
    tile_id = $1.to_i
    screen = Screen.new
    tiles[tile_id] = screen
  elsif line.empty?
    next
  else
    (0..(line.length - 1)).each do |x|
      screen[[x, y]] = line[x]
    end
    y += 1
  end
end

found = Hash.new { |h, k| h[k] = [] }
all_edges = Set[]

tiles.each do |tile_id, tile|
  tile.edges.each do |edge|
    catch :found do
      tiles.each do |other_tile_id, other_tile|
        next if tile_id == other_tile_id
        other_tile.edges.each do |other_edge|
          if other_edge == edge || other_edge == edge.reverse
            # if other_edge == edge
              found[tile_id] << other_tile_id
            # else
            #   found[tile_id] << -other_tile_id
            # end
            
            all_edges << edge
            all_edges << edge.reverse

            throw :found
          end
        end
      end
    end
  end
end

puts found.select { |k, v| v.count == 2 }.keys.inject(&:*)

corner = found.select { |k, v| v.count == 2 }.keys.first

dimensions = (found.count ** 0.5).to_i
layout = []
tiles_remaining = tiles.dup

row = []
tile = tiles[corner]
edges = tile.edges
while all_edges.include?(edges[0]) || all_edges.include?(edges[3])
  tile.rotate!
  edges = tile.edges
end
row << { tile_id: corner, tile: tile }

left_edge = tile.edges[1]
tile_id = corner

while row.count < dimensions

  found[tile_id].each do |side_id|
    tile = tiles[side_id]
    edges = tile.edges
    if edges.include?(left_edge) || edges.include?(left_edge.reverse)
      until edges[3] == left_edge || edges[3] == left_edge.reverse
        tile.rotate!
        edges = tile.edges
      end

      tile.flip! if edges[3] == left_edge.reverse

      left_edge = tile.edges[1]
      tile_id = side_id

      row << { tile_id: side_id, tile: tile }
    else
      next
    end

    break
  end

end

layout << row

while layout.count < dimensions
  row = []
  while row.count < dimensions
    upper_id = layout.last[row.count][:tile_id]
    bottom_edge = layout.last[row.count][:tile].edges[2]
    found[upper_id].each do |other_id|
      tile = tiles[other_id]
      edges = tile.edges
      if edges.include?(bottom_edge) || edges.include?(bottom_edge.reverse)
        until edges[0] == bottom_edge || edges[0] == bottom_edge.reverse
          tile.rotate!
          edges = tile.edges
        end

        tile.flop! if edges[0] == bottom_edge.reverse

        row << { tile_id: other_id, tile: tile }
      else
        next
      end

      break
    end
  end
  layout << row
end

map = Screen.new

base_y = 0
layout.each do |row|
  (1..8).each do |y|
    base_x = 0
    row.each do |aggregate|
      (1..8).each do |x|
        map[[base_x + x - 1, base_y + y - 1]] = aggregate[:tile][[x, y]]
      end
      base_x += 8
    end
  end
  base_y += 8
end

$monster1 = /^..................#./
$monster2 = /^#....##....##....###/
$monster3 = /^.#..#..#..#..#..#.../

def count(map)
  count = 0
  lines = map.to_s.chomp.split("\n")
  (0..(lines.count - 3)).each do |y|
    (0..(lines.first.length - 20)).each do |x|
      count += 1 if lines[y][x..] =~ $monster1 && lines[y + 1][x..] =~ $monster2 && lines[y + 2][x..] =~ $monster3
    end
  end
  count
end

i = 0
while (count = count(map)).zero?
  map.rotate!
  map.flip! if i % 5 == 4 # wasn't sure if % 4 == 3 was sufficient given that i was rotating at the same time, but i think it was. this is safe, anyway.
  i += 1
end

puts map.get_coordinates('#').count - count * 15