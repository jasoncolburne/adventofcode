#!/usr/bin/env ruby

require 'pp'

class Body
  attr_accessor :x, :y, :z, :vx, :vy, :vz

  def initialize(input)
    @x = input[:x]
    @y = input[:y]
    @z = input[:z]
    @vx = 0
    @vy = 0
    @vz = 0
  end

  def move
    @x += @vx
    @y += @vy
    @z += @vz
  end

  def accelerate(body)
    @vx += 1 if @x < body.x
    @vx -= 1 if @x > body.x
    @vy += 1 if @y < body.y
    @vy -= 1 if @y > body.y
    @vz += 1 if @z < body.z
    @vz -= 1 if @z > body.z
  end

  def potential_energy
    @x.abs + @y.abs + @z.abs
  end

  def kinetic_energy
    @vx.abs + @vy.abs + @vz.abs
  end

  def total_energy
    potential_energy * kinetic_energy
  end

  def to_s
    x, y, z, vx, vy, vz = [@x, @y, @z, @vx, @vy, @vz].map { |value| value.to_s.rjust(3, ' ') }
    "pos=<x=#{x}, y=#{y}, z=#{z}>, vel=<x=#{vx}, y=#{vy}, z=#{vz}>"
  end
end

class System
  def initialize(inputs)
    @bodies = inputs.map { |input| Body.new(input) }
    @inputs = inputs.dup
  end

  def matches_initial_state(dimension)
    case dimension
    when :x
      @inputs.map { |input| input[dimension] } == @bodies.map { |body| body.x } && @bodies.all? { |body| body.vx.zero? }
    when :y
      @inputs.map { |input| input[dimension] } == @bodies.map { |body| body.y } && @bodies.all? { |body| body.vy.zero? }
    when :z
      @inputs.map { |input| input[dimension] } == @bodies.map { |body| body.z } && @bodies.all? { |body| body.vz.zero? }
    else
      raise "unexpected input"
    end
  end

  def to_s
    @bodies.map(&:to_s).join("\n")
  end

  def total_energy
    @bodies.map(&:total_energy).inject(&:+)
  end

  def step
    @bodies.each do |body|
      other_bodies = @bodies - [body]
      other_bodies.each { |other| body.accelerate(other) }
    end
    @bodies.each(&:move)
  end
end

data = <<EOT
<x=-1, y=0, z=2>
<x=2, y=-10, z=-7>
<x=4, y=-8, z=8>
<x=3, y=5, z=-1>
EOT

data = <<EOT
<x=-8, y=-10, z=0>
<x=5, y=5, z=10>
<x=2, y=-7, z=3>
<x=9, y=-8, z=-3>
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")
inputs = lines.map { |line| line.gsub('<', '{').gsub('>', '}').gsub('=', ':') }.map { |line| eval(line) }
system = System.new(inputs)

x_cycle_length = nil
y_cycle_length = nil
z_cycle_length = nil
i = 0
while ![x_cycle_length, y_cycle_length, z_cycle_length].all?
  # puts "After #{i} steps:"
  # puts system.to_s
  # puts system.total_energy
  if i != 0
    x_cycle_length = i if system.matches_initial_state(:x) && !x_cycle_length
    y_cycle_length = i if system.matches_initial_state(:y) && !y_cycle_length
    z_cycle_length = i if system.matches_initial_state(:z) && !z_cycle_length
  end

  system.step
  i += 1
end

puts [x_cycle_length, y_cycle_length, z_cycle_length].reduce(1, :lcm)