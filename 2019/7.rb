#!/usr/bin/env ruby

require 'pp'
require './computer'

data = "[" + File.read(ARGV[0]) + "]"
program = eval(data)

# part A
# program = [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]
# program = [3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0]
# program = [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]

# part B
# program = [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]
# program = [3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10]

def amplify(program, phase, feedback = false)
  computer = Computer.new()
  
  computer.load_program('A', program, [phase[0], 0])
  computer.load_program('B', program, [phase[1]])
  computer.load_program('C', program, [phase[2]])
  computer.load_program('D', program, [phase[3]])
  computer.load_program('E', program, [phase[4]])
  
  computer.redirect('A', 'B')
  computer.redirect('B', 'C')
  computer.redirect('C', 'D')
  computer.redirect('D', 'E')
  computer.redirect('E', 'A') if feedback

  computer.execute_until_all_contexts_are_done
  feedback ? computer.find_context('A').inputs.last : computer.find_context('E').outputs.last
end

def determine_maximum_output(program)
  [0, 1, 2, 3, 4].permutation(5).map { |phase| amplify(program, phase) }.max
end

def determine_maximum_feedback_output(program)
  [5, 6, 7, 8, 9].permutation(5).map { |phase| amplify(program, phase, true) }.max
end

puts determine_maximum_output(program)
puts determine_maximum_feedback_output(program)