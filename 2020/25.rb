#!/usr/bin/env ruby

data = File.read(ARGV[0])

keys = data.chomp.split("\n").map(&:to_i)

def transform(subject_number, loop_size)
  value = 1
  loop_size.times do
    value *= subject_number
    value %= 20201227
  end
  value
end

loop_sizes = {}

# i could just find one loop_size (the smaller) but i'd like to verify
# my work by applying the transformation to both keys
loops = 0
value = 1
until keys.all? { |key| loop_sizes.include?(key) }
  value *= 7
  value %= 20201227
  loops += 1

  loop_sizes[value] = loops if keys.include?(value)
end

loop_sizes.each do |key, _loop_size|
  loop_size = loop_sizes.reject { |k, v| k == key }.values.first
  puts transform(key, loop_size)
end
