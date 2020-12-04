#!env ruby

require 'pp'

BASE_PATTERN = [0, 1, 0, -1]

def multiply_pattern(offset)
  [BASE_PATTERN[0]] * offset +
  [BASE_PATTERN[1]] * offset +
  [BASE_PATTERN[2]] * offset +
  [BASE_PATTERN[3]] * offset
end

def extend_pattern(pattern, length)
  # < and length + 1 work because we need to shift an element off the array before we use it
  new_pattern = pattern * (length < pattern.length ? 1 : ((length + 1).to_f / pattern.length.to_f).ceil.to_i)
  new_pattern[0..length]
end

def fft(input, iterations)
  iterations.times do 
    input = (1..input.length).map do |output|
      pattern = extend_pattern(multiply_pattern(output), input.length)
      pattern.shift
      input.zip(pattern).map { |a, b| a * b }.inject(&:+).abs % 10
    end
  end

  input
end

def compute_backwards_to_offset(input, offset, iterations)
  input = input[offset..]

  iterations.times do
    output = []
    accumulator = 0
    (input.length - 1).downto(0) do |j|
      accumulator += input[j]
      output << accumulator
    end
    input = output.reverse.map { |value| value % 10 }
  end

  input
end

data = File.read(ARGV[0]).chomp

# part 1
# data = "12345678"
# data = "80871224585914546619083218645595"
# data = "19617804207202209144916044189917"
# data = "69317163492948606335995924319873"

input = data.split('').map(&:to_i)
puts fft(input, ARGV[1].to_i)[0..7].map(&:to_s).join('')

# part 2
# data = "03036732577212944063491565474664"
# data = "02935109699940807407585447034323"
# data = "03081770884921959731165446850517"

input = data.split('').map(&:to_i) * 10_000
offset = data[0..6].to_i

raise "cannot fast compute!" if offset < input.length / 2

puts compute_backwards_to_offset(input, offset, ARGV[1].to_i)[0..7].map(&:to_s).join('')
