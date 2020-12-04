#!env ruby

require 'pp'
require './computer'

data = "[" + File.read(ARGV[0]) + "]"
program = eval(data)

# program = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
# program = [1102,34915192,34915192,7,4,7,99,0]
# program = [104,1125899906842624,99]

computer = Computer.new(true)
computer.load_program('Test', program, [ARGV[1].to_i])
computer.execute_until_all_contexts_are_done
puts computer.find_context('Test').outputs
