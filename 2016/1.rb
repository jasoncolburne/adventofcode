#!/usr/bin/env ruby

require 'pp'

data = File.read(ARGV[0]).chomp
#data = ''
instructions = data.split(', ')

position = [0, 0]
direction = 0
positions = { position => true }

instructions.each do |instruction|
  case instruction[0]
  when 'L'
    direction = (direction - 1) % 4
  when 'R'
    direction = (direction + 1) % 4
  end

  distance = instruction[1..].to_i

  distance.times do
    case direction
    when 0
      position = [position[0], position[1] + 1]
    when 1
      position = [position[0] + 1, position[1]]
    when 2
      position = [position[0], position[1] - 1]
    when 3
      position = [position[0] - 1, position[1]]
    end

    if positions.include?(position) && ARGV[1].to_i == 1
      pp 'found!'
      pp position
      pp position[0].abs + position[1].abs
      exit
    end
    
    positions[position] = true
  end
end

pp position[0].abs + position[1].abs
