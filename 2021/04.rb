#!/usr/bin/env ruby

data = <<EOT
7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
EOT

data = File.read(ARGV[0])

input = data.chomp.split("\n")

numbers = input.shift.split(',').map(&:to_i)

def parse_boards(lines)
  boards = []

  while lines.count > 0 do
    lines.shift

    board = []
    5.times { board << lines.shift.strip.split(/\s+/).map(&:to_i) }

    boards << board
  end

  boards
end

boards = parse_boards(input)

def winner?(board, numbers)
  return true if board.any? { |line| line.all? { |number| numbers.include?(number) } }
  return true if (0..4).any? { |index| board.all? { |line| numbers.include?(line[index]) } }
  false
end

def compute_score(board, numbers)
  numbers.last * board.flatten.reject { |number| numbers.include?(number) }.sum
end

def winning_board(boards, numbers)
  numbers.length.times do |limit|
    numbers_called = numbers[0..limit]

    if boards.any? { |board| winner?(board, numbers_called) }
      board = boards.select { |board| winner?(board, numbers_called) }.first  
      return [board, numbers_called]
    end
  end

  raise "No winner"
end

board, numbers_called = winning_board(boards, numbers)
puts compute_score(board, numbers_called)

def last_winning_board(boards, numbers)
  winners = []
  numbers.length.times do |limit|
    numbers_called = numbers[0..limit]

    winning_boards = boards.select { |board| winner?(board, numbers_called) }
    if winning_boards.count != winners.count
      winning_boards.each do |board|
        winners << board unless winners.include?(board)  # Wish I could use a set
      end
    end

    return [winners.last, numbers_called] if winners.count == boards.count
  end
end

board, numbers_called = last_winning_board(boards, numbers)
puts compute_score(board, numbers_called)
