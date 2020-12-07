#!/usr/bin/env ruby

data = <<EOT
light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.
EOT

data = <<EOT
shiny gold bags contain 2 dark red bags.
dark red bags contain 2 dark orange bags.
dark orange bags contain 2 dark yellow bags.
dark yellow bags contain 2 dark green bags.
dark green bags contain 2 dark blue bags.
dark blue bags contain 2 dark violet bags.
dark violet bags contain no other bags.
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")

contains = {}
lines.each do |line|
  line =~ /^(.+?) bags contain (.+?)\.$/
  key = $1
  values = {}
  $2.split(', ').each do |value|
    values[$2] = $1.to_i if value =~ /^(\d+) (.+?) bags?$/
  end
  contains[key] = values
end

def can_hold?(target, holder, contains)
  contains[holder].keys.include?(target) || contains[holder].keys.any? { |inner| can_hold?(target, inner, contains) }
end

puts contains.keys.select { |key| can_hold?('shiny gold', key, contains) }.count

# this will sum all bags including the top level bag, because it's more elegant
# just subtract one for the answer
def sum_bags(target, contains)
  1 + contains[target].map { |inner, count| count * sum_bags(inner, contains) }.inject(0, :+)
end

puts sum_bags('shiny gold', contains) - 1
