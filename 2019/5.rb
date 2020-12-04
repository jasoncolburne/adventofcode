#!env ruby

require 'pp'
require './computer'

data = "[" + File.read(ARGV.first) + "]"
program = eval(data)

computer = Computer.new(true)
computer.load_program('Test', program, [ARGV[1].to_i])
computer.execute_until_all_contexts_are_done
puts computer.find_context('Test').outputs
