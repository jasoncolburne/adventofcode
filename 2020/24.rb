#!/usr/bin/env ruby

require 'matrix'
require 'set'

data = <<EOT
sesenwnenenewseeswwswswwnenewsewsw
neeenesenwnwwswnenewnwwsewnenwseswesw
seswneswswsenwwnwse
nwnwneseeswswnenewneswwnewseswneseene
swweswneswnenwsewnwneneseenw
eesenwseswswnenwswnwnwsewwnwsene
sewnenenenesenwsewnenwwwse
wenwwweseeeweswwwnwwe
wsweesenenewnwwnwsenewsenwwsesesenwne
neeswseenwwswnwswswnw
nenwswwsewswnenenewsenwsenwnesesenew
enewnwewneswsewnwswenweswnenwsenwsw
sweneswneswneneenwnewenewwneswswnese
swwesenesewenwneswnwwneseswwne
enesenwswwswneneswsenwnewswseenwsese
wnwnesenesenenwwnenwsewesewsesesew
nenewswnwewswnenesenwnesewesw
eneswnwswnwsenenwnwnwwseeswneewsenese
neswnwewnwnwseenwseesewsenwsweewe
wseweeenwnesenwwwswnew
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")

# I think these hexagons are squashed but it won't affec the results
$vectors_by_direction = {
  'e' => Vector[2, 0],
  'w' => Vector[-2, 0],
  'nw' => Vector[-1, 1],
  'se' => Vector[1, -1],
  'ne' => Vector[1, 1],
  'sw' => Vector[-1, -1]
}

black_tiles = Set[]
lines.each do |line|
  steps = line.scan(/(e|w|ne|nw|se|sw)/).flatten
  tile = steps.map { |step| $vectors_by_direction[step] }.inject(&:+)
  if black_tiles.include?(tile)
    black_tiles.delete(tile)
  else
    black_tiles << tile
  end
end

puts black_tiles.count

def evolve(black_tiles)
  tiles_to_check = Set[]
  black_tiles.each do |tile|
    tiles_to_check << tile
    $vectors_by_direction.values.each do |vector|
      tiles_to_check << tile + vector
    end
  end

  new_black_tiles = Set[]

  tiles_to_check.each do |tile|
    adjacent_tiles = $vectors_by_direction.values.map { |vector| tile + vector }
    adjacent_black_tiles = adjacent_tiles.select { |adjacent_tile| black_tiles.include?(adjacent_tile) }.count
    if black_tiles.include?(tile)
      new_black_tiles << tile unless adjacent_black_tiles == 0 || adjacent_black_tiles > 2
    else
      new_black_tiles << tile if adjacent_black_tiles == 2
    end
  end

  new_black_tiles
end

(ARGV[1].to_i).times do
  black_tiles = evolve(black_tiles)
end

puts black_tiles.count
