#!env ruby

require 'pp'
require './screen'

data = <<EOT
abc

a
b
c

ab
ac

a
a
a
a

b
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")

groups = []
current_group = []
lines.each do |line|
  if line.empty?
    groups << current_group
    current_group = []
  else
    current_group = (current_group + line.split('')).uniq
  end
end
groups << current_group

puts groups.map(&:count).inject(&:+)

groups = []
current_group = []
new_group = true
lines.each do |line|
  if line.empty?
    groups << current_group
    current_group = []
    new_group = true
  else
    current_group = new_group ? line.split('').uniq : (line.split('').uniq.select { |char| current_group.include?(char) })
    new_group = false
  end
end
groups << current_group

puts groups.map(&:count).inject(&:+)
