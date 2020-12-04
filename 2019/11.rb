#!env ruby

require 'pp'
require './computer'

class Ship
  def paint(coordinates, color)
    _panel = panel(coordinates)
    _panel[:color] = color
    _panel[:painted] += 1   
  end

  def panel(coordinates)
    panels[coordinates.dup] ||= { color: 0, painted: 0 }
  end

  def panels
    # this is hacked for the second part of the challenge, return to {} for the first solution
    @panels ||= { [0,0] => { color: 1, painted: 0 } }
  end
end

class Robot
  attr_reader :ship

  def initialize(program, ship = Ship.new)
    @computer = Computer.new()
    @computer.load_program('Main', program, [])
    @ship = ship
    @coordinates = [0, 0]
    @direction = 0
  end

  def paint(color)
    panel = @ship.panel(@coordinates)
    # if panel[:color] != color
      panel[:painted] += 1
      panel[:color] = color
    # end
  end

  def turn_and_move(direction)
    if direction == 1 # right
      @direction = (@direction + 1) % 4
    else # left
      @direction = (@direction - 1) % 4
    end

    case @direction
    when 0 # up
      @coordinates[1] += 1
    when 1 # right
      @coordinates[0] += 1
    when 2 # down
      @coordinates[1] -= 1
    when 3 # left
      @coordinates[0] -= 1
    else
      raise "unexpected error"
    end
  end

  def simulate_painting!
    context = @computer.find_context('Main')
    while !@computer.halted? do
      context.inputs << @ship.panel(@coordinates)[:color]
      @computer.step while context.outputs.count < 2 && !@computer.halted?
      color_to_paint = context.outputs.shift
      direction_to_turn = context.outputs.shift
      paint(color_to_paint)
      turn_and_move(direction_to_turn)
    end
  end
end

data = "[" + File.read(ARGV[0]) + "]"
program = eval(data)

ship = Ship.new
robot = Robot.new(program, ship)
robot.simulate_painting!
puts ship.panels.values.select{ |panel| panel[:painted] > 0 }.count

x_values = ship.panels.keys.map { |coordinates| coordinates[0] }
y_values = ship.panels.keys.map { |coordinates| coordinates[1] }

x_min = x_values.min
x_max = x_values.max
y_min = y_values.min
y_max = y_values.max

y_max.downto(y_min) do |y|
  (x_min..x_max).each do |x|
    panel = ship.panel([x, y])
    print panel[:color] == 1 ? 'X' : ' '
  end
  puts
end