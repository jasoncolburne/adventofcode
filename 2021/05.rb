#!/usr/bin/env ruby

data = <<EOT
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
EOT

data = File.read(ARGV[0])

input = data.chomp.split("\n")

vents = []

input.each do |vent_input|
  vent_input =~ /(\d+),(\d+) -> (\d+),(\d+)/
  vent = [[$1.to_i, $2.to_i], [$3.to_i, $4.to_i]]
  vents << vent
end

def evaluate_terrain(vents, no_diagonals = false)
  vents = vents.select { |vent| vent[0][0] == vent[1][0] || vent[0][1] == vent[1][1] } if no_diagonals

  max_x = vents.map { |vent| [vent[0][0], vent[1][0]].max }.max
  max_y = vents.map { |vent| [vent[0][1], vent[1][1]].max }.max
  
  row = [0] * (max_x + 1)
  terrain = []
  (max_y + 1).times do
    terrain << row.dup
  end
  
  vents.each do |vent|
    x1, y1 = vent[0]
    x2, y2 = vent[1]

    delta_x = (x2 - x1).abs
    delta_y = (y2 - y1).abs

    if delta_y > delta_x
      if delta_x.zero?
        min_y = [y1, y2].min
        max_y = [y1, y2].max
    
        (min_y..max_y).each { |y| terrain[y][x1] += 1 }
      else
        raise if delta_y % delta_x > 0

        x_step = (x2 > x1) ? 1 : -1
        y_step = (y2 - y1) / (x2 - x1).abs
        x = x1
        y = y1

        ((x2 - x1).abs + 1).times do
          terrain[y][x] += 1

          x += x_step
          y += y_step
        end
      end
    else
      if delta_y.zero?
        min_x = [x1, x2].min
        max_x = [x1, x2].max
    
        (min_x..max_x).each { |x| terrain[y1][x] += 1 }
      else
        raise if delta_x % delta_y > 0

        x_step = (x2 - x1) / (y2 - y1).abs
        y_step = (y2 > y1) ? 1 : -1
        x = x1
        y = y1

        ((y2 - y1).abs + 1).times do
          terrain[y][x] += 1

          x += x_step
          y += y_step
        end
      end
    end
  end

  terrain
end

terrain = evaluate_terrain(vents, true)
puts terrain.flatten.select { |level_at_point| level_at_point > 1 }.count

terrain = evaluate_terrain(vents)
puts terrain.flatten.select { |level_at_point| level_at_point > 1 }.count
