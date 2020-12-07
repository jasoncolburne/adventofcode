#!/usr/bin/env ruby

require 'pp'

layers = []

pixels = File.read(ARGV[0]).chomp

offset = 0
width = 25
height = 6
chunk_size = width * height
while offset < pixels.length
  layers << pixels.slice(offset, chunk_size)
  offset += chunk_size
end

layer = layers.sort_by { |layer| layer.count('0') }.first
puts layer.count('1') * layer.count('2')

def merge_layers(layers, chunk_size)
  result = " " * chunk_size
  layers.each do |layer|
    layer.bytes.each_with_index do |byte, index|
      case byte.chr
      when '2'
        result[index] = '2' if result[index] == ' '
      when '1', '0'
        result[index] = byte.chr if [' ', '2'].include?(result[index])
      end
    end
  end
  result
end

result = merge_layers(layers, chunk_size)

offset = 0
lines = []
while offset < result.length
  lines << result.slice(offset, width)
  offset += width
end

puts lines.map { |line| line.gsub('0', '█').gsub('1', ' ') }
