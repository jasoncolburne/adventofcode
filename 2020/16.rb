#!/usr/bin/env ruby

require 'set'

data = File.read(ARGV[0])

lines = data.chomp.split("\n")

ranges = []
i = 0
until lines[i] == ''
  lines[i] =~ /^\w+: (\d+)-(\d+) or (\d+)-(\d+)$/
  ranges << (($1.to_i)..($2.to_i))
  ranges << (($3.to_i)..($4.to_i))
  i += 1
end

i += 1
raise "unexpected line" unless lines[i] =~ /^your ticket:$/
i += 1
# ticket line
i += 1
# blank line
i += 1
raise "unexpected line" unless lines[i] =~ /^nearby tickets:$/
i += 1

sum = 0
while i < lines.count
  lines[i].split(',').map(&:to_i).each do |n|
    sum += n unless ranges.any? { |range| range.include?(n) }
  end
  i += 1
end

puts sum

ranges = {}
i = 0
until lines[i] == ''
  lines[i] =~ /^([\w\s]+): (\d+)-(\d+) or (\d+)-(\d+)$/
  ranges[($2.to_i)..($3.to_i)] = $1
  ranges[($4.to_i)..($5.to_i)] = $1
  i += 1
end

i += 1
raise "unexpected line" unless lines[i] =~ /^your ticket:$/
i += 1
my_ticket = lines[i].split(',').map(&:to_i)
i += 1
# blank line
i += 1
raise "unexpected line" unless lines[i] =~ /^nearby tickets:$/
i += 1

length = my_ticket.count

all_possible_values = []
while i < lines.count
  values = lines[i].split(',').map(&:to_i)
  if values.any? { |n| ranges.keys.none? { |range| range.include?(n) } }
    i += 1
    next
  end
  
  possible_values = []
  (0..(length - 1)).each do |i|
    possible_values << ranges.select { |range, label| range.include?(values[i]) }.values.to_set
  end
  all_possible_values << possible_values

  i += 1
end

label_possibilities = (0..(length - 1)).map do |i|
  all_possible_values.map { |possible_values| possible_values[i] }.inject(&:intersection)
end

until label_possibilities.all? { |possibilities| possibilities.count == 1 }
  (0..(length - 1)).each do |i|
    if label_possibilities[i].count == 1
      (0..(length - 1)).each do |j|
        next if i == j
        label_possibilities[j] -= label_possibilities[i]
      end
    end
  end
end

labels = label_possibilities.map(&:to_a).map(&:first)
puts labels.zip(my_ticket).to_h.select { |label, value| label =~ /^departure/ }.values.inject(&:*)