#!/usr/bin/env ruby

require 'set'

data = "389125467"
data = "685974213"

cups = data.split('').map(&:to_i)

(1..100).each do |index|
  cup = cups.shift
  picked_up = []
  3.times { picked_up << cups.shift }
  cups.unshift(cup)
  destination = cup - 1
  until (destination_index = cups.index(destination))
    destination -= 1
    destination = cups.max if destination < cups.min 
  end
  cups = cups[0..destination_index] + picked_up + cups[(destination_index + 1)..]
  cups << cups.shift
end

while cups.first != 1
  cups << cups.shift
end

puts cups[1..].map(&:to_s).join

class Cup
  attr_accessor :next, :previous, :value

  def initialize(value)
    @value = value
  end
end

def create_cups(initial_cups, total_cups)
  cups = {}

  previous_cup = nil
  initial_cups.each do |i|
    cup = Cup.new(i)
    cups[i] = cup
    if previous_cup
      cup.previous = previous_cup
      previous_cup.next = cup
    end
    previous_cup = cup
  end

  min = initial_cups.max + 1
  max = total_cups - initial_cups.count + min - 1

  if min < max
    (min..max).each do |i|
      cup = Cup.new(i)
      cups[i] = cup
      cup.previous = previous_cup
      previous_cup.next = cup
      previous_cup = cup
    end
  end

  previous_cup.next = cups[initial_cups.first]
  cups[initial_cups.first].previous = previous_cup

  cups
end

initial_cups = data.split('').map(&:to_i)
cups = create_cups(initial_cups, 1000000)

cup = cups[initial_cups.first]
10000000.times do
  value = cup.value

  c1 = cup.next
  c2 = c1.next
  c3 = c2.next

  cup.next = c3.next
  cup.next.previous = cup

  destination_value = value > 1 ? value - 1 : 1000000

  taken_values = Set[c1.value, c2.value, c3.value]
  while taken_values.include?(destination_value)
    destination_value = destination_value > 1 ? destination_value - 1 : 1000000
  end

  destination_cup = cups[destination_value]

  c3.next = destination_cup.next
  c3.next.previous = c3
  destination_cup.next = c1
  c1.previous = destination_cup

  cup = cup.next
end

puts cups[1].next.value * cups[1].next.next.value
