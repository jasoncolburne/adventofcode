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
  attr_reader :rolls
  attr_reader :p1_score
  attr_reader :p2_score

  def initialize(p1_start, p2_start)
    @p1_position = p1_start - 1
    @p2_position = p2_start - 1
    @p1_score = 0
    @p2_score = 0

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
    loop do
      move(1)
      return if @p1_score >= @winning_score
      move(2)
      return if @p2_score >= @winning_score
    end
  end

  def sum_triple_roll
    roll_die + roll_die + roll_die
  end

  def roll_die
    @die.next
  end

  def move(player)
    case player
    when 1
      @p1_position += sum_triple_roll
      @p1_position %= 10
      @p1_score += @p1_position + 1
    when 2
      @p2_position += sum_triple_roll
      @p2_position %= 10
      @p2_score += @p2_position + 1
    end
  end
end

game = Game.new(p1_start, p2_start)
game.advance_until_done
p game.rolls * [game.p1_score, game.p2_score].min

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
