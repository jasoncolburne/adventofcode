#!/usr/bin/env ruby

require 'pp'
require './computer'
require './screen'

program = eval("[" + File.read(ARGV[0]) + "]")
screen = Screen.new

run_program = ->(coordinates) do
  computer = Computer.new
  computer.load_program('Main', program, coordinates.dup)
  computer.execute_until_all_contexts_are_done
  outputs = computer.find_context('Main').outputs
  value = outputs.shift
  screen[coordinates] = (value == 1 ? '#' : '.')
end

iteration = ARGV[1].to_i
while true
  puts iteration
  0.upto(iteration) do |x|
    run_program.call([x, iteration])
  end
  # 0.upto(iteration - 1) do |y|
  #   run_program.call([iteration, y])
  # end
  # screen.display(true)

  position = screen.find_rectangle(100, 100, '#')
  break unless position.nil?
  iteration += 1
end

puts position[0] * 10_000 + position[1]