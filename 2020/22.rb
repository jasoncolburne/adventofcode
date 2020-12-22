#!/usr/bin/env ruby

require 'digest'
require 'set'

data = <<EOT
Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10
EOT

data = <<EOT
Player 1:
43
19

Player 2:
2
29
14
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")

players = Hash.new { |h, k| h[k] = [] }
current_player = nil
lines.each do |line|
  if line =~ /^Player (\d+):$/
    current_player = $1.to_i
  elsif line =~ /^(\d+)$/
    players[current_player] << $1.to_i
  end 
end

players_dup = {}
players_dup[1] = players[1].dup
players_dup[2] = players[2].dup

round = 1
until players.any? { |k, v| v.empty? }
  player_1_card = players[1].shift
  player_2_card = players[2].shift

  if player_1_card >= player_2_card
    players[1] += [player_1_card, player_2_card]
  else
    players[2] += [player_2_card, player_1_card]
  end

  round += 1
end

score = 0
players.reject { |k, v| v.empty? }.values.first.reverse.each_with_index do |card, index|
  score += card * (index + 1)
end

puts score

$md5 = Digest::MD5.new
$game = 1

def game(players)
  game = $game
  $game += 1

  digests = Set[]
  round = 1
  until players.any? { |k, v| v.empty? }
    $md5.reset

    digest = $md5.hexdigest(players.to_s)
    return 1 if digests.include?(digest)
    digests << digest

    player_1_card = players[1].shift
    player_2_card = players[2].shift
  
    if player_1_card <= players[1].count && player_2_card <= players[2].count
      new_players = { 1 => players[1][0..(player_1_card - 1)], 2 => players[2][0..(player_2_card - 1)]}
      winner = game(new_players)
      loser = winner == 1 ? 2 : 1
      players[winner] += eval("[player_#{winner}_card, player_#{loser}_card]")
    else
      if player_1_card >= player_2_card
        players[1] += [player_1_card, player_2_card]
      else
        players[2] += [player_2_card, player_1_card]
      end  
    end

    round += 1
  end

  winner = players.reject { |k, v| v.empty? }.keys.first

  if game == 1
    score = 0
    players.reject { |k, v| v.empty? }.values.first.reverse.each_with_index do |card, index|
      score += card * (index + 1)
    end
    score
  else
    winner
  end
end

puts game(players_dup)