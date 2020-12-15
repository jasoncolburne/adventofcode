#!/usr/bin/env ruby

data = [10,16,6,0,1,17]
#data = [1,3,2]
#data = [0,3,6]

# i did the main loop in a confusing way, i think.
def number_spoken(initial_numbers, n)
  spoken = {}
  last_spoken = nil
  initial_numbers.each_with_index do |number, i|
    spoken[number] = i
    last_spoken = number
  end

  last_spoken_first = true
  ((initial_numbers.count)..(n - 1)).each do |i|
    next_spoken = if last_spoken_first
      0
    else
      i - spoken[last_spoken] - 1
    end
    spoken[last_spoken] = i - 1

    last_spoken_first = !spoken.include?(next_spoken)
    last_spoken = next_spoken
  end

  last_spoken
end

puts number_spoken(data, ARGV[0].to_i)
