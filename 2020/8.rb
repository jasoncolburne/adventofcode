#!/usr/bin/env ruby

require 'set'

data = <<EOT
nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
EOT

data = File.read(ARGV[0])

class Computer
  attr_accessor :eip, :acc, :program

  def initialize(instructions)
    @program = instructions.chomp.split("\n")
    @eip = 0
    @acc = 0
  end

  def step
    @program[@eip] =~ /^(acc|jmp|nop) ([+\-]\d+)$/

    instruction = $1
    parameter = $2.to_i

    case instruction
    when 'acc'
      @acc += parameter
      @eip += 1
    when 'jmp'
      @eip += parameter
    when 'nop'
      @eip += 1
    else
      raise "unrecognized instruction"
    end

    @eip
  end
end

visited_instructions = Set[0]
computer = Computer.new(data)
until visited_instructions.include?(latest_eip = computer.step) do
  visited_instructions << latest_eip
  last_acc = computer.acc
end
puts last_acc

def swap_instruction(line)
  line.include?('jmp') ? line.gsub!('jmp', 'nop') : line.gsub!('nop', 'jmp')
end

target_eip = computer.program.length
(0..(target_eip - 1)).each do |index|
  computer.acc = 0
  computer.eip = 0
  
  if computer.program[index] =~ /^(jmp|nop)/
    swap_instruction(computer.program[index])
  else
    next
  end

  visited_instructions = Set[0]
  until computer.eip == target_eip || visited_instructions.include?(latest_eip = computer.step) do
    visited_instructions << latest_eip
  end

  if computer.eip == target_eip
    puts computer.acc
    exit
  end

  swap_instruction(computer.program[index]) if computer.program[index] =~ /^(jmp|nop)/
end
