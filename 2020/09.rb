#!/usr/bin/env ruby

data = <<EOT
35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576
EOT

data = File.read(ARGV[0])

numbers = data.chomp.split("\n").map(&:to_i)
preamble_count = ARGV[1].to_i

def sum_in_pairs?(sum, pairs)
  pairs.each do |x|
    others = (pairs - [x]).uniq
    return true if others.any? { |y| x + y == sum }
  end
  false
end

preamble = numbers[0..(preamble_count - 1)]
remaining = numbers[preamble_count..]

found = nil
remaining.each do |number|
  unless sum_in_pairs?(number, preamble)
    found = number
    break
  end
  preamble.shift
  preamble << number
end

puts found

(0..(numbers.count - 1)).each do |i|
  (i..(numbers.count - 1)).each do |j|
    slice = numbers[i..j]
    sum = slice.inject(&:+)
    if sum == found
      puts slice.max + slice.min
      exit
    elsif sum > found
      break
    end 
  end
end
