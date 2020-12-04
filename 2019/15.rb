#!env ruby

require 'pp'
require './computer'
require './screen'

class Robot
  def initialize(program, debug = false)
    @computer = Computer.new(debug)
    @screen = Screen.new(background: '██')
    @context = @computer.load_program('Main', program)
    @x = 0
    @y = 0
  end

  def random_direction_preferring_unvisited
    potentials = (1..4).to_a.map { |direction| { direction: direction, coordinates: new_coordinates(direction) } }
    unexplored = potentials.select { |aggregate| @screen[aggregate[:coordinates]].nil? }
    if unexplored.empty?
      potentials.reject { |aggregate| @screen[aggregate[:coordinates]] == '█' }
    else
      unexplored
    end.shuffle.first[:direction]
  end

  def explore_area
    @screen[[0, 0]] = 'OO'

    begin
      while true
        direction = random_direction_preferring_unvisited
        new_coordinates = new_coordinates(direction)      
        @context.inputs << direction
        @computer.step # we need this to unblock ourselves, not a big fan
        @computer.execute_until_all_contexts_blocked
        output = @context.outputs.shift

        unless new_coordinates == [0, 0]
          case output
          when 0
            @screen[new_coordinates] = '██'
          when 1
            @screen[new_coordinates] = '  '
          when 2
            @screen[new_coordinates] = 'XX'
          else
            raise "unexpected output from robot (#{output})!"
          end
        end

        if [1, 2].include?(output)
          @x = new_coordinates[0]
          @y = new_coordinates[1]
        end

        @screen.display(true)
      end
    rescue Interrupt
      @screen.write('./15-maze.txt')
      raise
    end
  end

  private

  def new_coordinates(direction)
    case direction
    when 1
      [@x, @y - 1]
    when 2
      [@x, @y + 1]
    when 3
      [@x - 1, @y]
    when 4
      [@x + 1, @y]
    else
      raise "unexpected direction!"
    end
  end
end

# program = eval("[" + File.read(ARGV[0]) + "]")
# Robot.new(program).explore_area

map = File.read(ARGV[0])
lines = map.chomp.split("\n")

origin = nil
oxygen = nil

maze = {}
lines.each_with_index do |line, y|
  line.split('').each_with_index do |character, x|
    next if x % 2 == 1 # the maze is doubled for a squarer aspect

    maze[[x / 2, y]] = case character
    when '█'
      :wall
    when 'O'
      origin = [x / 2, y]
      :origin
    when ' '
      :path
    when 'X'
      oxygen = [x / 2, y]
      :oxygen
    else
      raise "unexpected character!"
    end
  end
end

def get_next_coordinates(position, maze, path)
  x = position[0]
  y = position[1]
  [[x, y + 1], [x, y - 1], [x + 1, y], [x - 1, y]].reject do |coordinates|
    maze[coordinates] == :wall || maze[coordinates].nil? || path.include?(coordinates)
  end
end

def find_path(position, oxygen, maze, path = [])
  return path if position == oxygen

  path = path.dup
  path << position
  next_coordinates = get_next_coordinates(position, maze, path)

  path = next_coordinates.map do |coordinates|
    {
      coordinates: coordinates,
      path: find_path(coordinates, oxygen, maze, path)
    }
  end.reject do |aggregate|
    aggregate[:path].empty?
  end.sort_by do |aggregate|
    aggregate[:path].size
  end.map do |aggregate|
    aggregate[:path]
  end.first

  path || [] 
end

puts find_path(origin, oxygen, maze).size

# part 2

minutes = 0
while maze.values.include?(:path)
  maze.select { |coordinates, state| state == :oxygen }.keys.each do |coordinates|
    get_next_coordinates(coordinates, maze, []).each do |adjacent|
      maze[adjacent] = :oxygen
    end
  end

  minutes += 1
end

puts minutes