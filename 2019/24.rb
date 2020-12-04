#!env ruby

require 'pp'
require './screen'
require './adjacent_cells'

data = <<EOT
....#
#..#.
#.?##
..#..
#....
EOT

data = File.read(ARGV[0])

module Enumerable
  def map_with_index
    r = []
    each_with_index do |e, i|
      r << yield(e, i)
    end
    r
  end
end

# basically finite automata
class Eris
  include AdjacentCells

  attr_reader :biodiversity

  def initialize(data)
    @state = Screen.new
    @state.fill_from_text(data)
    @biodiversities = []
    @biodiversity = nil
    @duplicated_state = false
  end

  def x_values
    @x_values ||= @state.x_values
  end

  def y_values
    @y_values ||= @state.y_values
  end

  def step
    compute_biodiversity

    if @biodiversities.include?(@biodiversity)
      @duplicated_state = true
      return
    end

    @biodiversities << @biodiversity

    new_state = Screen.new

    y_values.each do |y|
      x_values.each do |x|
        new_state[[x, y]] = determine_next_state([x, y])
      end
    end

    @state = new_state
  end

  def determine_next_state(coordinates)
    adjacent_bugs = adjacent_cells(coordinates).select { |cell| bug_at(cell) }.count

    if bug_at(coordinates)
      adjacent_bugs == 1 ? '#' : '.'
    else
      [1, 2].include?(adjacent_bugs) ? '#' : '.'
    end
  end

  def bug_at(coordinates)
    @state[coordinates] == '#'
  end

  def compute_biodiversity
    buffer = StringIO.new
    @state.output(buffer)
    @biodiversity = buffer.string.gsub("\n", '').split('').map_with_index do |character, index|
      character == '#' ? (1 << index) : 0
    end.inject(&:+)
  end

  def wait_for_duplicate_state
    step until @duplicated_state
  end

  def show
    @state.display
  end
end

eris = Eris.new(data)
eris.wait_for_duplicate_state
pp eris.biodiversity

# part 2
class ErisDeux
  def initialize(data)
    @states = {}
    @states[0] = Screen.new
    @states[0].fill_from_text(data)
  end

  def x_values
    @x_values ||= @states[0].x_values
  end

  def y_values
    @y_values ||= @states[0].y_values
  end

  def step
    new_states = {}
    levels = ((levels_with_bugs.min - 1)..(levels_with_bugs.max + 1))
    levels.each { |level| new_states[level] = Screen.new }

    levels.each do |level|
      y_values.each do |y|
        x_values.each do |x|
          new_states[level][[x, y]] = determine_next_state(level, [x, y])
        end
      end
    end

    @states = new_states

    @states.delete(levels.min) if @states[levels.min].get_coordinates('#').count == 0
    @states.delete(levels.max) if @states[levels.max].get_coordinates('#').count == 0
  end

  def determine_next_state(level, coordinates)
    adjacent_bugs = adjacent_cells(level, coordinates).select { |_level, cell| bug_at(_level, cell) }.count

    if bug_at(level, coordinates)
      adjacent_bugs == 1 ? '#' : '.'
    else
      [1, 2].include?(adjacent_bugs) ? '#' : '.'
    end
  end

  def levels_with_bugs
    levels = @states.select { |k,v| v.get_coordinates('#').count > 0 }.keys
    (levels.min..levels.max)
  end

  def adjacent_cells(level, coordinates)
    case coordinates
    # row 0 - looks correct
    when [0,0] # A
      [[level, [0,1]], [level, [1,0]], [level-1, [1,2]], [level-1, [2,1]]]
    when [1,0] # B
      [[level, [0,0]], [level, [2,0]], [level, [1,1]], [level-1, [2,1]]]
    when [2,0] # C
      [[level, [1,0]], [level, [3,0]], [level, [2,1]], [level-1, [2,1]]]
    when [3,0] # D
      [[level, [2,0]], [level, [4,0]], [level, [3,1]], [level-1, [2,1]]]
    when [4,0] # E
      [[level, [3,0]], [level, [4,1]], [level-1, [3,2]], [level-1, [2,1]]]
    # row 1 - looks correct
    when [0,1] # F
      [[level, [0,2]], [level, [1,1]], [level, [0,0]], [level-1, [1,2]]]
    when [1,1] # G
      [[level, [0,1]], [level, [1,0]], [level, [1,2]], [level, [2,1]]]
    when [2,1] # H/8
      [[level, [1,1]], [level, [2,0]], [level, [3,1]], [level+1, [0,0]], [level+1, [1,0]], [level+1, [2,0]], [level+1, [3,0]], [level+1, [4,0]]]
    when [3,1] # I
      [[level, [2,1]], [level, [4,1]], [level, [3,0]], [level, [3,2]]]
    when [4,1] # J
      [[level, [4,0]], [level, [3,1]], [level, [4,2]], [level-1, [3,2]]]
    # row 2
    when [0,2] # K
      [[level, [0,1]], [level, [1,2]], [level, [0,3]], [level-1, [1,2]]]
    when [1,2] # L/12
      [[level, [1,1]], [level, [0,2]], [level, [1,3]], [level+1, [0,0]], [level+1, [0,1]], [level+1, [0,2]], [level+1, [0,3]], [level+1, [0,4]]]
    when [2,2] # ?
      []
    when [3,2] # N/14
      [[level, [3,1]], [level, [4,2]], [level, [3,3]], [level+1, [4,0]], [level+1, [4,1]], [level+1, [4,2]], [level+1, [4,3]], [level+1, [4,4]]]
    when [4,2]
      [[level, [4,1]], [level, [3,2]], [level, [4,3]], [level-1, [3,2]]]
    # row 3
    when [0,3]
      [[level, [0,2]], [level, [1,3]], [level, [0,4]], [level-1, [1,2]]]
    when [1,3]
      [[level, [0,3]], [level, [1,2]], [level, [2,3]], [level, [1,4]]]
    when [2,3]
      [[level, [1,3]], [level, [2,4]], [level, [3,3]], [level+1, [0,4]], [level+1, [1,4]], [level+1, [2,4]], [level+1, [3,4]], [level+1, [4,4]]]
    when [3,3]
      [[level, [2,3]], [level, [4,3]], [level, [3,4]], [level, [3,2]]]
    when [4,3]
      [[level, [4,2]], [level, [3,3]], [level, [4,4]], [level-1, [3,2]]]
      # row 4
    when [0,4]
      [[level, [0,3]], [level, [1,4]], [level-1, [2,3]], [level-1, [1,2]]]
    when [1,4]
      [[level, [0,4]], [level, [1,3]], [level, [2,4]], [level-1, [2,3]]]
    when [2,4]
      [[level, [1,4]], [level, [2,3]], [level, [3,4]], [level-1, [2,3]]]
    when [3,4]
      [[level, [2,4]], [level, [3,3]], [level, [4,4]], [level-1, [2,3]]]
    when [4,4]
      [[level, [3,4]], [level, [4,3]], [level-1, [2,3]], [level-1, [3,2]]]
    else
      raise "unexpected coordinates!"
    end
  end

  def bug_at(level, coordinates)
    @states[level] && @states[level][coordinates] == '#'
  end

  def wait(minutes)
    minutes.times { step }
  end

  def show
    @states.keys.each do |level|
      puts "Depth #{level}:"
      @states[level].display
      puts
    end
  end

  def count_bugs_present
    @states.values.map { |screen| screen.get_coordinates('#').count }.inject(&:+)
  end
end

eris = ErisDeux.new(data)
eris.wait(ARGV[1].to_i)
# eris.show
puts eris.count_bugs_present

