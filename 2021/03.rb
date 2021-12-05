#!/usr/bin/env ruby

data = <<EOT
00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010
EOT

data = File.read(ARGV[0])

numbers = data.chomp.split("\n")

def derive(numbers, method)
  sums = [0] * numbers.first.length

  numbers.each do |number|
    number.chars.each_with_index do |bit, index|
      sums[index] += (bit == '1' ? 1 : -1)
    end
  end
  
  if method == :most_common
    sums.map { |digit| digit > 0 ? '1' : '0' }.join('').to_i(2)
  elsif method == :least_common
    sums.map { |digit| digit < 0 ? '1' : '0' }.join('').to_i(2)
  else
    raise
  end
end

def derive_gamma(numbers)
  derive(numbers, :most_common)
end

def derive_epsilon(numbers)
  derive(numbers, :least_common)
end

puts derive_gamma(numbers) * derive_epsilon(numbers)

def oxygen_generator_rating(numbers)
  data = numbers.dup
  data.first.length.times do |index|
    counter = 0
    data.each { |number| counter += (number[index] == '1' ? 1 : -1) }

    target = (counter >= 0 ? '1' : '0')
    data.select! { |number| number[index] == target }
  
    break if data.count == 1
  end

  data.first.to_i(2)
end

def co2_scrubber_rating(numbers)
  data = numbers.dup
  data.first.length.times do |index|
    counter = 0
    data.each { |number| counter += (number[index] == '1' ? 1 : -1) }

    target = (counter < 0 ? '1' : '0')
    data.select! { |number| number[index] == target }
  
    break if data.count == 1
  end

  data.first.to_i(2)
end

def life_support_rating(data)
  oxygen_generator_rating(data) * co2_scrubber_rating(data)
end

puts life_support_rating(numbers)
