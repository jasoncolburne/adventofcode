#!/usr/bin/env ruby

require 'set'
require 'rubygems'
require 'bundler/setup'
require 'jason/math'

require './screen'

data = <<EOT
Player 1 starting position: 4
Player 2 starting position: 8
EOT

data = File.read(ARGV[0])
lines = data.chomp.split("\n")

p1_start = lines.first.split(': ').last.to_i
p2_start = lines.last.split(': ').last.to_i

class Game
  attr_reader :rolls, :scores

  def initialize(p1_start, p2_start)
    @positions = [p1_start - 1, p2_start - 1]
    @scores = [0, 0]

    @winning_score = 1000
    @rolls = 0
    @die = Enumerator.new do |yielder|
      loop do
        (1..100).each do |n|
          @rolls += 1
          yielder << n
        end
      end
    end
  end

  def advance_until_done
    player = 0
    loop do
      move(player)
      return if @scores[player] >= @winning_score

      player += 1
      player %= 2
    end
  end

  def sum_triple_roll
    roll_die + roll_die + roll_die
  end

  def roll_die
    @die.next
  end

  def move(player)
    @positions[player] += sum_triple_roll
    @positions[player] %= 10
    @scores[player] += @positions[player] + 1
  end
end

game = Game.new(p1_start, p2_start)
game.advance_until_done
p game.rolls * game.scores.min

all_sums = (1..3).map { |a| (1..3).map { |b| (1..3).map { |c| a + b + c } } }.flatten
counted_sums = Hash.new(0)
all_sums.each do |sum|
  counted_sums[sum] += 1
end

player = 0
universes = { [[p1_start - 1, p2_start - 1], [0, 0]] => 1 }
wins = [0] * 2
until universes.empty?
  accumulator = Hash.new(0)
  universes.each_pair do |state, universe_count|
    positions, scores = state
    new_positions = positions.dup
    new_scores = scores.dup

    counted_sums.each_pair do |sum, sum_count|
      new_positions[player] = (positions[player] + sum) % 10
      new_scores[player] = (scores[player] + new_positions[player] + 1)

      if new_scores[player] >= 21
        wins[player] += universe_count * sum_count
        next
      end

      accumulator[[new_positions.dup, new_scores.dup]] += universe_count * sum_count
    end
  end
  universes = accumulator
  player += 1
  player %= 2
end

p wins.max
