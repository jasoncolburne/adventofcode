#!/usr/bin/env ruby

data = File.read(ARGV[0])

lines = data.chomp.split("\n")

# taken from: https://gist.github.com/nickmcdonnough/8396f889810bdc8154e87d7cf8414c35
# and fixed.
class MathParser
  attr_reader :expression, :output, :operators, :postfix

  PRECEDENCE = {
    '^' => 3,
    '*' => 2,
    '/' => 2,
    '+' => 1,
    '-' => 1,
  }

  def initialize(expression, precedence = PRECEDENCE)
    @expression = expression
    @precedence = precedence
    @output, @operators = [], []
  end

  def split_expression
    pieces = expression.scan(/\d+|[\^*\/+\-\(\)]/)

    pieces.each do |x|
      if x =~ /\d/
        output << x
      else
        adjust_operators(x)
      end
    end
  end

  def adjust_operators(op)
    if op == ')'
      until operators.last == '('
        output << operators.pop
      end
      operators.pop
    else
      until operators.last == '(' || @precedence[op].nil? || operators.empty? || @precedence[operators.last] < @precedence[op]
        output << operators.pop
      end
      operators << op
    end
  end

  def create_postfix
    @postfix ||= output + operators.reverse
  end

  def calculate
    postfix.each_with_object([]) do |token, stack|
      if !@precedence[token]
        stack << token
      else
        op1, op2 = stack.pop(2)
        stack << eval("#{op1}#{token}#{op2.to_f}")
      end
    end.first
  end
end

pp (lines.map do |line|
  parser = MathParser.new(line, { '*' => 1, '+' => 1 })
  parser.split_expression
  parser.create_postfix
  parser.calculate
end).sum.to_i

pp (lines.map do |line|
  parser = MathParser.new(line, { '*' => 1, '+' => 2 })
  parser.split_expression
  parser.create_postfix
  parser.calculate
end).sum.to_i
