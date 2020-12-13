#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'jason/math'

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

index = -1
buses = lines.last.split(',')
mapping = (buses.map do |bus|
  index += 1

  case bus
  when 'x'
    nil
  when /\d+/
    bus_id = bus.to_i
    [bus_id, (bus_id - index) % bus_id]
  else
    raise "unexpected bus"
  end
end).compact.to_h

puts Math.chinese_remainder_theorem(mapping)