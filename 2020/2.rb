#!/usr/bin/env ruby

data = <<EOT
1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")
good = lines.select do |line|
  line =~ /(\d+)-(\d+) (\w): (.+)/
  min = $1.to_i
  max = $2.to_i
  count = $4.count($3)
  count <= max && count >= min
end
puts good.count

lines = data.chomp.split("\n")
good = lines.select do |line|
  line =~ /(\d+)-(\d+) (\w): (.+)/
  i = $1.to_i
  j = $2.to_i
  ($4[i - 1] == $3 && $4[j - 1] != $3) || ($4[i - 1] != $3 && $4[j - 1] == $3)
end
puts good.count