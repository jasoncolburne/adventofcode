#!env ruby

require 'pp'
require './computer'

computer = Computer.new false
program = eval("[" + File.read(ARGV[0]) + "]")
contexts = []
(0..49).each do |i|
  contexts << computer.load_program("#{i}", program, [i, -1])
end

nat_x = nil
nat_y = nil
delivered = true

# this seemed to output 4 times for every value, but in the end it repeated the correct number more
# than 4 times so i was still able to complete the challenge

loop do
  computer.execute_until_halted_or_blocked!
  contexts.each do |context|
    while context.outputs.count >= 3
      address = context.outputs.shift
      x = context.outputs.shift
      y = context.outputs.shift

      # puts "#{context.name} -> #{address}: #{x}, #{y}"
      # exit if address == 255

      if address != 255
        contexts[address].inputs << x
        contexts[address].inputs << y
      else
        nat_x = x
        nat_y = y
        delivered = false
      end
    end
  end

  if computer.all_blocked? && nat_x
    delivered = true
    puts "255 -> 0: #{nat_x}, #{nat_y}"
    contexts[0].inputs << nat_x
    contexts[0].inputs << nat_y
  else
    contexts.each do |context|
      if context.blocked? && context.inputs.empty?
        context.inputs << -1
        context.step
      end
    end
  end

  computer.step_all
end
