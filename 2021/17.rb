#!/usr/bin/env ruby

data = "target area: x=20..30, y=-10..-5"
data = File.read(ARGV[0]).chomp

target = data.scan(/target area: x=([-\d\.]+), y=([-\d\.]+)/).first.map { |range_string| eval(range_string) }

step = -> vx, vy do
  hit, x, y, y_max = false, 0, 0, 0

  while true
    x += vx
    y += vy

    vx -= vx > 0 ? 1 : vx < 0 ? -1 : 0
    vy -= 1

    y_max = y if y > y_max

    if target[0].include?(x) && target[1].include?(y)
      hit = true
      break
    end

    break if x > target[0].max || y < target[1].min
  end

  [hit, x, y, y_max]
end

target_hit_records = (3..50).to_a.product((-1000..1000).to_a).map { |vx, vy| step.call(vx, vy) }.select { |record| record.first }

puts target_hit_records.map { |record| record.last }.max
puts target_hit_records.count
