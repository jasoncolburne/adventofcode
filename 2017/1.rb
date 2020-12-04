#!env ruby

data = File.read(ARGV[0]).chomp

numbers = data.split('').map(&:to_i)

accumulator = 0
last = numbers[-1]
numbers.each do |i|
  accumulator += i if i == last
  last = i
end
puts accumulator

accumulator = 0
offset = numbers.count / 2
numbers.each_with_index do |n, i|
  accumulator += n if n == numbers[(offset + i) % numbers.count]
end
puts accumulator