#!/usr/bin/env ruby

require 'openssl'

data = <<EOT
939
7,13,x,x,59,x,31,19
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")
earliest = lines.first.to_i
buses = lines.last.split(',').reject { |s| s == 'x' }.map(&:to_i)

departures_by_bus = (buses.map do |bus|
  minimum = 0
  while minimum < earliest do
    minimum += bus    
  end

  [bus, minimum]
end).to_h

minimum = departures_by_bus.values.min
single = departures_by_bus.select { |bus, minutes| minutes == minimum }
puts single.keys.first * (single.values.first - earliest)

def chinese_remainder_theorem(mapping)
  max = mapping.keys.inject(&:*)
  series = mapping.to_a.map { |m, r| (r * max * (max/m).to_bn.mod_inverse(m) / m) }
  series.inject(&:+) % max     
end

index = -1
buses = lines.last.split(',')
mapping = (buses.map do |bus|
  index += 1

  case bus
  when 'x'
    nil
  when /\d+/
    [bus.to_i, bus.to_i - index]
  else
    raise "unexpected bus"
  end
end).compact.to_h

puts chinese_remainder_theorem(mapping)