#!env ruby

require 'pp'

data = File.read(ARGV[0]).chomp

puts data.count('(') - data.count(')')

floor = 0
data.split('').each_with_index do |paren, i|
  case paren
  when '('
    floor += 1
  when ')'
    floor -= 1
  end

  if floor < 0
    puts i + 1
    break
  end
end