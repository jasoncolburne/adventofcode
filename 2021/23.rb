#!/usr/bin/env ruby

require 'set'
require 'rubygems'
require 'bundler/setup'
require 'jason/math'
require 'ruby-prof'

require './screen'

data = <<EOT
#############
#...........#
###B#C#B#D###
  #A#D#C#A#
  #########
EOT

data = File.read(ARGV[0])

@cost = {
  'A' => 1,
  'B' => 10,
  'C' => 100,
  'D' => 1000
}.freeze

@home_room = {
  'A' => 0,
  'B' => 1,
  'C' => 2,
  'D' => 3
}.freeze

@entries = {
  0 => 2,
  1 => 4,
  2 => 6,
  3 => 8
}.freeze

def parse_data(data, solve_part1 = true)
  room_size, inject_part2 = if solve_part1
                              [2, false]
                            else
                              [4, true]
                            end

  home_state = [[], [], [], []]
  hallway_state = nil

  lines = data.chomp.split("\n")
  lines.each do |line|
    if line =~ /#(\w)#(\w)#(\w)#(\w)#/
      (0..3).each do |i|
        home_state[i] << Regexp.last_match(i + 1)
      end

      if inject_part2
        home_state[0] += %w[D D]
        home_state[1] += %w[C B]
        home_state[2] += %w[B A]
        home_state[3] += %w[A C]
        inject_part2 = false
      end
    end
    hallway_state = Regexp.last_match(1).length.times.map { nil } if line =~ /#(\.+)#/
  end

  @target_home_state = [
    (['A'] * room_size).freeze,
    (['B'] * room_size).freeze,
    (['C'] * room_size).freeze,
    (['D'] * room_size).freeze
  ].freeze
  @room_range = 0..3
  @hallway_range = 0..(hallway_state.length - 1)
  @hallway_seats = @hallway_range.to_a - @entries.values

  [home_state, hallway_state]
end

# order by cheapest I suppose? it doesn't really matter if we brute the whole thing
def find_by_door_unsettled(home)
  (0..3).map do |room|
    first = first_unsettled(home, room)
    first && [room, home[room].index(first)]
  end.compact
end

# whether or not the amphipod closest to the door is settled into their position
# returns false if they will need to move in the future
def first_unsettled(home, room)
  amphipod = home[room].compact.first
  if amphipod.nil?
    nil
  elsif room != @home_room[amphipod]
    amphipod
  else
    settled?(home, room) ? nil : amphipod
  end
end

def blocked?(hallway, entry, seat)
  range = if entry < seat
            entry..seat
          else
            seat..entry
          end

  !hallway[range].all?(&:nil?)
end

# settled does not mean finished. it means the amphipods present in the room will not move again
# but there may be a missing amphipod in the hallway
def settled?(home, room)
  set = home[room].compact.to_set
  set.length <= 1 && (set.first.nil? || @home_room[set.first] == room)
end

def find_in_hallway_to_settle(home, hallway)
  @hallway_seats.each.map do |seat|
    amphipod = hallway[seat]

    # no amphipod found here
    next if amphipod.nil?

    # can't move into a room if the inhabitants will move
    room = @home_room[amphipod]
    next unless settled?(home, room)

    # can't move if we're blocked
    entry = @entries[room]
    range = if entry <= seat
              entry..(seat - 1)
            else
              (seat + 1)..entry
            end
    next unless hallway[range].compact.empty?

    # candidate found
    seat
  end.compact
end

def potential_states(home, hallway)
  find_by_door_unsettled(home).map do |room, seat|
    new_home = []
    home.each { |seats| new_home << seats.dup }
    amphipod = new_home[room][seat]
    new_home[room][seat] = nil

    entry = @entries[room]
    @hallway_seats.map do |hallway_seat|
      new_hallway = hallway.dup

      next if blocked?(new_hallway, entry, hallway_seat)

      new_hallway[hallway_seat] = amphipod
      steps = (entry - hallway_seat).abs + seat + 1
      expended = steps * @cost[amphipod]

      [new_home, new_hallway, expended]
    end.compact
  end.flatten(1) \
  + \
  find_in_hallway_to_settle(home, hallway).map do |hallway_seat|
    new_home = []
    home.each { |seats| new_home << seats.dup }

    amphipod = hallway[hallway_seat]
    new_hallway = hallway.dup
    new_hallway[hallway_seat] = nil

    room = @home_room[amphipod]
    room_seat = new_home[room].each_index.select { |seat| new_home[room][seat].nil? }.last

    new_home[room][room_seat] = amphipod

    entry = @entries[room]
    steps = (hallway_seat - entry).abs + room_seat + 1
    expended = steps * @cost[amphipod]

    [new_home, new_hallway, expended]
  end
end

@best = Float::INFINITY
@solutions = {}

def solve(home, hallway, energy = 0)
  solution = @solutions[[home, hallway]]
  return energy + solution if solution

  potential_states = potential_states(home, hallway).sort_by { |state| state[2] }.reverse
  cost = potential_states.map do |new_home, new_hallway, new_energy|
    total_energy = energy + new_energy

    if new_home == @target_home_state
      total_energy
    else
      solve(new_home, new_hallway, total_energy)
    end
  end.compact.min
  @solutions[[home, hallway]] = cost ? cost - energy : Float::INFINITY

  cost
end

p solve(*parse_data(data))
p solve(*parse_data(data, false))
