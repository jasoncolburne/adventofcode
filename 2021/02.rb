#!/usr/bin/env ruby

data = <<EOT
forward 5
down 5
forward 8
up 3
down 8
forward 2
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")

def evaluate_position_v1(commands)
  x = 0
  y = 0

  commands.each do |line|
    line =~ /^(\w+) (\d+)$/
    command, distance = $1, $2.to_i

    case command
    when 'forward'
      x += distance
    when 'down'
      y += distance
    when 'up'
      y -= distance
    else
      raise
    end
  end

  [x, y]
end

def evaluate_position_v2(commands)
  x = 0
  y = 0
  aim = 0

  commands.each do |line|
    line =~ /^(\w+) (\d+)$/
    command, distance = $1, $2.to_i

    case command
    when 'forward'
      x += distance
      y += distance * aim
    when 'down'
      aim += distance
    when 'up'
      aim -= distance
    else
      raise
    end
  end

  [x, y]
end

x, y = evaluate_position_v1(lines)
puts x * y

x, y = evaluate_position_v2(lines)
puts x * y
