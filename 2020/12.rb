#!/usr/bin/env ruby

data = <<EOT
F10
N3
F7
R90
F11
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")

position = [0, 0]
direction = 0 # east. 1 = south, 2 = west, 3 = north

lines.each do |line|
  line =~ /^([NSEWLRF])(\d+)$/
  command = $1
  units = $2.to_i

  case command
  when 'N'
    position = [position[0], position[1] + units]
  when 'S'
    position = [position[0], position[1] - units]
  when 'E'
    position = [position[0] + units, position[1]]
  when 'W'
    position = [position[0] - units, position[1]]
  when 'L'
    steps = units / 90
    direction = (direction - steps) % 4
  when 'R'
    steps = units / 90
    direction = (direction + steps) % 4
  when 'F'
    case direction
    when 0
      position = [position[0] + units, position[1]]
    when 1
      position = [position[0], position[1] - units]
    when 2
      position = [position[0] - units, position[1]]
    when 3
      position = [position[0], position[1] + units]
    end
  else
    raise "unexpected command #{command}"
  end
end

puts position[0].abs + position[1].abs

waypoint = [10, 1]
ship = [0, 0]

lines.each do |line|
  line =~ /^([NSEWLRF])(\d+)$/
  command = $1
  units = $2.to_i

  case command
  when 'N'
    waypoint = [waypoint[0], waypoint[1] + units]
  when 'S'
    waypoint = [waypoint[0], waypoint[1] - units]
  when 'E'
    waypoint = [waypoint[0] + units, waypoint[1]]
  when 'W'
    waypoint = [waypoint[0] - units, waypoint[1]]
  when 'L'
    steps = (units / 90) % 4
    steps.times do 
      waypoint = [waypoint[1] * -1, waypoint[0]]
    end
  when 'R'
    steps = (units / 90) % 4
    steps.times do 
      waypoint = [waypoint[1], waypoint[0] * -1]
    end
  when 'F'
    ship = [ship[0] + waypoint[0] * units, ship[1] + waypoint[1] * units]
  else
    raise "unexpected command #{command}"
  end
end

puts ship[0].abs + ship[1].abs