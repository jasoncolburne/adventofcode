#!/usr/bin/env ruby

require 'set'

data = <<EOT
16
10
15
5
1
11
7
19
6
12
4
EOT

data = <<EOT
28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3
EOT

data = File.read(ARGV[0])

numbers = data.chomp.split("\n").map(&:to_i).sort

differences = {
  1 => 0,
  2 => 0,
  3 => 0
}
prev = 0
numbers.each do |number|
  differences[number - prev] += 1
  prev = number
end
differences[3] += 1

puts differences[1] * differences[3]

def count_configurations_to_outlet(adapters, adapter, cache)
  return 1 if adapter.zero?
  return 0 unless adapters.include?(adapter)
  cache[adapter] ||= (1..3).map { |n| count_configurations_to_outlet(adapters, adapter - n, cache) }.inject(0, :+)
end

adapters = numbers.to_set
adapters << 0
adapters << numbers.last + 3

puts count_configurations_to_outlet(adapters, numbers.last + 3, {})
