#!/usr/bin/env ruby

require 'set'
require 'rubygems'
require 'bundler/setup'
require 'jason/math'

require './screen'

data = <<EOT
6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5
EOT

data = File.read(ARGV[0])
input = data.chomp.split("\n")

screen = Screen.new
instructions = []
input.each do |line|
  next if line.empty?
  if line =~ /^fold/
    instruction, value_text = line.split('=')
    value = value_text.to_i
    if instruction =~ /x/
      instructions << [:vertical, value]
    else
      instructions << [:horizontal, value]
    end
  else
    x, y = line.split(',').map(&:to_i)
    screen[[x, y]] = '#'
  end
end

instructions.each_with_index do |(method, value), index|
  screen.send("fold_#{method}!".to_sym, value)
  puts screen.find_matches(/#/).size if index.zero?
end

screen.write
