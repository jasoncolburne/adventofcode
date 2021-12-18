#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'jason/math'

class Integer
  def split!(parent)
    Pair.new(self / 2, (to_f / 2).ceil, parent)
  end

  def magnitude
    self
  end

  def splittable?
    self >= 10
  end

  def to_pair
    self
  end
end

class Array
  def to_pair
    Pair.new(self[0].to_pair, self[1].to_pair)
  end
end

class Pair
  attr_accessor :parent
  attr_accessor :pair

  def self.parse(line)
    eval(line).to_pair
  end

  def initialize(left, right, parent = nil)
    @parent = parent
    @pair = [left, right]
    left.parent = self if left.is_a? Pair
    right.parent = self if right.is_a? Pair
  end

  def dup
    Pair.new(left.dup, right.dup)
  end

  def +(other)
    Pair.new(self, other)
  end

  def left
    @pair[0]
  end

  def left=(other)
    @pair[0] = other
  end

  def right
    @pair[1]
  end

  def right=(other)
    @pair[1] = other
  end

  def explodable?
    !!@parent&.parent&.parent&.parent && left.is_a?(Integer) && right.is_a?(Integer)
  end

  def explode_sub_pair!
    if explodable?
      explode!
      return true
    end

    return true if left.is_a?(Pair) && left.explode_sub_pair!
    return true if right.is_a?(Pair) && right.explode_sub_pair!

    false
  end

  def split_sub_number!
    if left.is_a?(Pair)
      split = left.split_sub_number!
      return true if split
    elsif left.splittable?
      self.left = left.split!(self)
      return true
    end

    if right.is_a?(Integer)
      if right.splittable?
        self.right = right.split!(self)
        return true
      end
    else
      split = right.split_sub_number!
      return true if split
    end

    false
  end

  def add_left(n, origin, descending)
    return @parent&.add_left(n, self, false) || false if left == origin

    if left.is_a? Integer
      self.left = left + n
      true
    elsif descending
      left.add_left(n, nil, true)
    else
      left.add_right(n, nil, true)
    end
  end

  def add_right(n, origin, descending)
    return @parent&.add_right(n, self, false) || false if right == origin

    if right.is_a?(Integer)
      self.right = right + n
      true
    elsif descending
      right.add_right(n, nil, true)
    else
      right.add_left(n, nil, true)
    end
  end

  def explode!
    @parent.add_left(left, self, false)
    @parent.add_right(right, self, false)

    if @parent.left == self
      @parent.left = 0
    elsif @parent.right == self
      @parent.right = 0
    end
  end

  def reduce!
    mutated = explode_sub_pair! || split_sub_number!
    reduce! if mutated

    mutated
  end

  def magnitude
    3 * left.magnitude + 2 * right.magnitude
  end

  def to_s
    "[#{@pair[0]}, #{@pair[1]}]"
  end
end

data = <<EOT
[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
EOT

# data = <<EOT
# [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
# [7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
# [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
# [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
# [7,[5,[[3,8],[1,4]]]]
# [[2,[2,2]],[8,[8,1]]]
# [2,9]
# [1,[[[9,3],9],[[9,0],[0,7]]]]
# [[[5,[7,4]],7],1]
# [[[[4,2],2],6],[8,7]]
# EOT

# data = <<EOT
# [1,1]
# [2,2]
# [3,3]
# [4,4]
# [5,5]
# [6,6]
# EOT

# data = <<EOT
# [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
# [7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
# EOT

# data = <<EOT
# [[[[4,3],4],4],[7,[[8,4],9]]]
# [1,1]
# EOT

data = File.read(ARGV[0])
lines = data.chomp.split("\n")
pairs = lines.map { |line| Pair.parse(line) }
pair = pairs.inject do |sum, local_pair|
  result = sum + local_pair
  result.reduce!
  result
end

p pair.magnitude

data = File.read(ARGV[0])
lines = data.chomp.split("\n")
pairs = lines.map { |line| Pair.parse(line) }
p (pairs.permutation(2).map do |(a, b)|
  x = a.dup + b.dup
  x.reduce!
  x.magnitude
end).max
