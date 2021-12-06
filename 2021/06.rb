#!/usr/bin/env ruby

data = <<EOT
3,4,3,1,2
EOT

data = File.read(ARGV[0])

input = data.chomp.split("\n")
numbers = input.first.split(',').map(&:to_i)

def step(numbers)
  new_numbers = []
  eights = 0

  numbers.each do |number|
    if number.zero?
      new_numbers << 6
      eights += 1
    else
      new_numbers << number - 1
    end
  end

  new_numbers + [8] * eights
end

def count_fish(initial_fish, generations)
  # track when the fish are due to duplicate
  # we need 9 slots since a newly created fish
  # duplicates in 9 days
  fish_cycles = [0] * 9

  # count the initial state and see how many
  # fish will be duplicated each day
  initial_fish.each { |days_left| fish_cycles[days_left] += 1 }

  # iterate through generations, and for each set of fish due
  # to duplicate, add their count to the set due to duplicate
  # in the future
  generations.times { |generation| fish_cycles[(generation + 7) % 9] += fish_cycles[generation % 9] }

  fish_cycles.sum
end

fish = numbers
80.times { fish = step(fish) }
puts fish.count

(1..32).each do |n|
  fish = numbers
  n.times { fish = step(fish) }
  counted_fish = count_fish(numbers, n)
  if fish.count != counted_fish
    pp fish
    raise "#{fish.count} != #{counted_fish} (n = #{n})"
  end
end

puts count_fish(numbers, 256)
