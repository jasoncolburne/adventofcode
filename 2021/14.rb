#!/usr/bin/env ruby

require 'set'
require 'rubygems'
require 'bundler/setup'
require 'jason/math'

require './screen'

data = <<EOT
NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
EOT

data = File.read(ARGV[0])
lines = data.chomp.split("\n")

template = lines.shift
lines.shift
$formulae = lines.map do |line|
  a, b = line.split(' -> ')
  [a, b]
end.to_h

def solve(key_counts, generations)
  generations.times do
    new_counts = Hash.new(0)
    key_counts.each_pair do |key, count|
      new_counts["#{key[0]}#{$formulae[key]}"] += count
      new_counts["#{$formulae[key]}#{key[1]}"] += count
    end
    key_counts = new_counts.dup
  end

  key_counts
end

key_counts = Hash.new(0)
(0..(template.length - 2)).each do |i|
  key_counts[template[i..(i+1)]] += 1
end

key_counts = solve(key_counts, 10)

histogram = Hash.new(0)
key_counts.each_pair do |key, count|
  histogram[key[0]] += count
end
histogram[template[-1]] += 1

min = histogram.values.min
max = histogram.values.max

puts max - min

key_counts = Hash.new(0)
(0..(template.length - 2)).each do |i|
  key_counts[template[i..(i+1)]] += 1
end

key_counts = solve(key_counts, 40)

histogram = Hash.new(0)
key_counts.each_pair do |key, count|
  histogram[key[0]] += count
end
histogram[template[-1]] += 1

min = histogram.values.min
max = histogram.values.max

puts max - min
