#!/usr/bin/env ruby

require 'pp'
require 'set'
require './screen'

data = <<EOT
mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0
EOT

data = <<EOT
mask = 000000000000000000000000000000X1001X
mem[42] = 100
mask = 00000000000000000000000000000000X0XX
mem[26] = 1
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")

memory = Hash.new(0)
mask = "X" * 36
lines.each do |line|
  if line =~ /^mask = ([X10]+)$/
    mask = $1
  elsif line =~ /^mem\[(\d+)\] = (\d+)$/
    offset = $1.to_i
    value = $2.to_i

    to_write = value.to_s(2).rjust(36, '0')
    (0..35).each do |i|
      next if mask[i] == 'X'

      to_write[i] = mask[i]
    end

    memory[offset] = to_write.to_i(2)
  else
    raise "unexpected format"
  end
end

puts memory.values.sum

def permutations(offset, floating)
  return [offset] if floating.empty?

  i = floating.shift
  off = offset.dup
  on = offset.dup
  off[i] = '0'
  on[i] = '1'
  permutations(on, floating.dup) + permutations(off, floating.dup)
end

memory = Hash.new(0)
mask = "0" * 36
lines.each do |line|
  if line =~ /^mask = ([X10]+)$/
    mask = $1
  elsif line =~ /^mem\[(\d+)\] = (\d+)$/
    offset = $1.to_i.to_s(2).rjust(36, '0')
    value = $2.to_i

    floating = []
    (0..35).each do |i|
      next if mask[i] == '0'

      if mask[i] == '1'
        offset[i] = '1'
      else
        floating << i
      end
    end

    permutations(offset, floating).each do |offset|
      memory[offset.to_i(2)] = value
    end
  else
    raise "unexpected format"
  end
end

puts memory.values.sum
