#!/usr/bin/env ruby

data = <<EOT
1721
979
366
299
675
1456
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")
numbers = lines.map(&:to_i)

collected = []
numbers.each do |n|
  if other = collected.find { |i| i + n == 2020 }
    puts other * n
    break
  end
  collected << n
end

collected = []
numbers.each do |n|
  others = collected.select { |i| i + n < 2020 }
  unless others.empty?
    others.each do |i|
      last = (others - [i]).find { |x| x + i + n == 2020 }
      if last
        puts last * n * i
        exit
      end
    end
  end
  collected << n
end
