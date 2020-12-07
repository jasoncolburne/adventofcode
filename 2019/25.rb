#!/usr/bin/env ruby

require 'pp'
require './computer'

input = [
  "south",
  "take space law space brochure",
  "south",
  "take mouse",
  "south",
  "take astrolabe",
  "south",
  "take mug",
  "north",
  "north",
  "west",
  "north",
  "north",
  "take wreath",
  "south",
  "south",
  "east",
  "north",
  "west",
  "take sand",
  "north",
  "take manifold",
  "south",
  "west",
  "take monolith",
  "west"
].map { |string| string + "\n" }.join('').bytes

program = eval('[' + File.read(ARGV[0]) + ']')

computer = Computer.new
context = computer.load_program('Main', program, input)

def brute_force(i, context, computer)
  items = ["space law space brochure", "mouse", "astrolabe", "mug", "wreath", "sand", "manifold", "monolith"]
  commands = []

  items.size.times do |j|
    puts i
    commands << ((i & (1 << j)).zero? ? "drop " : "take ") + items[j]
  end

  (commands + ["west"]).map { |command| command + "\n" }.join('')
end

i = 0
loop do
  computer.execute_until_halted_or_blocked!
  ascii = context.output_as_ascii
  print ascii
  if ascii =~ /proceed/ || i > 255
    input = STDIN.gets
  else
    input = brute_force(i, context, computer)
    i += 1
  end

  context.receive_ascii(input)
  computer.step
end