#!/usr/bin/env ruby

require 'set'
require 'rubygems'
require 'bundler/setup'
require 'jason/math'
require 'ruby-prof'

require './screen'

data = <<EOT
v...>>.vv>
.vv>>.vv..
>>.>v>...v
>>v>>.>.v.
v>v.vv.v..
>.>>..v...
.vv..>.>v.
v.v..>>v.v
....v..v.>
EOT

data = File.read(ARGV[0])

def equal?(map_a, map_b)
  return false unless map_a.display_buffer.count == map_b.display_buffer.count

  map_a.display_buffer.each_pair do |coordinates, value|
    return false if value != map_b.display_buffer[coordinates]
  end

  true
end

def evolve(map, x_max, y_max)
  new_map = Screen.new(background: '.')
  
  map.display_buffer.each_pair do |(x, y), value|
    next unless value == '>'

    key = [(x + 1) % x_max, y]

    if map[key]
      new_map[[x, y]] = value
    else
      new_map[key] = value
    end
  end

  map.display_buffer.each_pair do |(x, y), value|
    next unless value == 'v'

    key = [x, (y + 1) % y_max]

    if map[key] == 'v' || new_map[key]
      new_map[[x, y]] = value
    else
      new_map[key] = value
    end
  end

  new_map
end

new_map = Screen.new(background: '.').fill_from_text(data, '.')
x_max = new_map.x_max + 1
y_max = new_map.y_max + 1

map = evolve(new_map, x_max, y_max)

i = 0
until equal?(new_map, map)
  map = new_map
  new_map = evolve(map, x_max, y_max)
  i += 1
end

p i
