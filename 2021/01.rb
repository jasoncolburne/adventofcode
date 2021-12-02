#!/usr/bin/env ruby

data = <<EOT
199
200
208
210
200
207
240
269
260
263
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")
numbers = lines.map(&:to_i)

def evaluate_windows(original_numbers, window_size = 1)
  numbers = original_numbers.dup

  last = nil
  increased = 0
  bound = window_size - 1
  (numbers.count - bound).times do
    current = numbers[0..bound].sum
    increased += 1 if last != nil && current > last
  
    last = current
    numbers.shift
  end

  increased
end

puts evaluate_windows(numbers, 1)
puts evaluate_windows(numbers, 3)
