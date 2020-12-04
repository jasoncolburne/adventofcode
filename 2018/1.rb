#!env ruby

lines = IO.readlines(ARGV[0])

numbers = lines.map(&:chomp).map(&:to_i)
puts ([ARGV[1].to_i] + numbers).inject(&:+)

counter = 0
freqs = { 0 => true }
while true
  numbers.each do |i|
    counter += i
    if freqs.include?(counter)
      puts counter
      exit
    end
    freqs[counter] = true
  end
end
