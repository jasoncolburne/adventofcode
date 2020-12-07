#!/usr/bin/env ruby

require 'pp'
require './computer'
require './screen'

spring_script = <<EOT
NOT C J 
AND D J 
NOT A T 
OR T J
WALK
EOT

spring_script = <<EOT
NOT B J 
NOT C T
OR T J
AND D J
AND H J
NOT A T
OR T J 
RUN
EOT

program = eval("[" + File.read(ARGV[0]) + "]")
computer = Computer.new
screen = Screen.new

computer.load_program('Main', program, [])
context = computer.find_context('Main')
computer.execute_until_all_contexts_blocked

puts context.outputs.map(&:chr).join('')

spring_script.split('').map(&:ord).each do |integer|
  context.inputs << integer
end

computer.execute_until_all_contexts_are_done

# puts context.outputs.map(&:chr).join('')
puts context.outputs
