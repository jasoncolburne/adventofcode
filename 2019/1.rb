#!env ruby

def fuel(mass, recurse = true)
  _fuel = (mass / 3).to_i - 2
  return _fuel unless recurse
  _fuel + (fuel(_fuel, false) > 0 ? fuel(_fuel) : 0)
end

lines = IO.readlines(ARGV.first)
puts lines.map(&:chomp).map(&:to_i).map { |mass| fuel(mass, false) }.inject(&:+)
puts lines.map(&:chomp).map(&:to_i).map { |mass| fuel(mass) }.inject(&:+)
