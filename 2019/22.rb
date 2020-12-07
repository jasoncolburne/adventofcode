#!/usr/bin/env ruby

require 'pp'

data = <<EOT
deal with increment 7
deal into new stack
deal into new stack
EOT

data = <<EOT
cut 6
deal with increment 7
deal into new stack
EOT

data = <<EOT
deal with increment 7
deal with increment 9
cut -2
EOT

data = <<EOT
deal into new stack
cut -2
deal with increment 7
cut 8
cut -4
deal with increment 7
cut 3
deal with increment 9
deal with increment 3
cut -1
EOT

data = File.read(ARGV[0])

def deal(deck)
  deck.reverse
end

def cut(deck, quantity)
  deck[quantity..] + deck[0..(quantity - 1)]
end

def deal_with_increment(deck, increment)
  new_deck = deck.dup
  count = deck.count
  deck.each_with_index do |card, index|
    new_deck[(index * increment) % count] = card
  end
  new_deck
end

def runner(commands, deck)
  commands.each do |command|
    case command
    when /deal into new stack/
      deck = deal(deck)
    when /cut ([-\d]+)/
      deck = cut(deck, $1.to_i)
    when /deal with increment (\d+)/
      deck = deal_with_increment(deck, $1.to_i)
    else
      raise "unknown command!"
    end
  end

  deck
end

# Returns an array of the form `[gcd(x, y), a, b]`, where
# `ax + by = gcd(x, y)`.
#
# @param [Integer] x
# @param [Integer] y
# @return [Array<Integer>]
def gcdext(x, y)
  if x < 0
    g, a, b = gcdext(-x, y)
    return [g, -a, b]
  end
  if y < 0
    g, a, b = gcdext(x, -y)
    return [g, a, -b]
  end
  r0, r1 = x, y
  a0 = b1 = 1
  a1 = b0 = 0
  until r1.zero?
    q = r0 / r1
    r0, r1 = r1, r0 - q*r1
    a0, a1 = a1, a0 - q*a1
    b0, b1 = b1, b0 - q*b1
  end
  [r0, a0, b0]
end

# Returns the inverse of `num` modulo `mod`.
#
# @param [Integer] num the number
# @param [Integer] mod the modulus
# @return [Integer]
# @raise ZeroDivisionError if the inverse of `base` does not exist
def invert(num, mod)
  g, a, b = gcdext(num, mod)
  unless g == 1
    raise ZeroDivisionError.new("#{num} has no inverse modulo #{mod}")
  end
  a % mod
end

def repeat(multiplier, constant, iterations, modulo)
  return [multiplier % modulo, constant % modulo] if iterations == 1

  if iterations % 2 == 0
    m2, c2 = repeat(multiplier, constant, iterations / 2, modulo)
    final_m = (m2 * m2) % modulo
    final_c = (m2 * c2 + c2) % modulo
    [final_m, final_c]
  else
    m1, c1 = repeat(multiplier, constant, iterations - 1, modulo)
    final_m = (multiplier * m1) % modulo
    final_c = (multiplier * c1 + constant) % modulo
    [final_m, final_c]
  end
end

def runner2(commands, deck_size, iterations, initial_offset)
  multiplier = 1
  constant = 0

  commands.each do |command|
    case command
    when /deal into new stack/
      multiplier = -multiplier
      constant = -1 - constant
    when /cut ([-\d]+)/
      constant = constant - $1.to_i
    when /deal with increment (\d+)/
      increment = $1.to_i
      multiplier *= increment
      constant *= increment
    else
      raise "unknown command!"
    end

    multiplier %= deck_size
    constant %= deck_size
  end

  inverse_multiplier = invert(multiplier, deck_size)
  inverse_constant = (-inverse_multiplier * constant) % deck_size

  repeated_inverse_multiplier, repeated_inverse_constant = repeat(
    inverse_multiplier, inverse_constant, iterations, deck_size
  )

  (initial_offset * repeated_inverse_multiplier + repeated_inverse_constant) % deck_size
end

commands = data.chomp.split("\n")

deck = (0..10006).to_a
# deck = (0..9).to_a

pp runner(commands, deck).index(2019)

pp runner2(commands, 119315717514047, 101741582076661, 2020)