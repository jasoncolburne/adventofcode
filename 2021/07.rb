#!/usr/bin/env ruby

data = <<EOT
16,1,2,0,4,2,7,1,2,14
EOT

data = File.read(ARGV[0])

input = data.chomp.split("\n")
positions = input.first.split(',').map(&:to_i)

max = positions.max
min = positions.min

sums = (min..max).map do |final_position|
  positions.map { |position| (position - final_position).abs }.sum
end

pp sums.min

sums = (min..max).map do |final_position|
  positions.map do |position|
    delta = (position - final_position).abs
    (delta + 1) * delta / 2
  end.sum
end

pp sums.min
