#!/usr/bin/env ruby

require 'set'
require 'rubygems'
require 'bundler/setup'
require 'jason/math'
require 'ruby-prof'

require './screen'

data = <<EOT
inp w
add z w
mod z 2
div w 2
add y w
mod y 2
div w 2
add x w
mod x 2
div w 2
mod w 2
EOT

data = File.read(ARGV[0])

# ========================
# reference implementation
# ========================
class Instruction
  OPCODES = %i[inp add mul div mod eql].to_set.freeze

  def initialize(opcode, *params)
    raise "Unknown opcode '#{opcode}'" unless OPCODES.include?(opcode)

    @opcode = opcode
    @params = params.dup
  end

  def execute(alu, inputs)
    other = lambda do
      @params.last.is_a?(Symbol) ? alu.registers[@params.last] : @params.last
    end

    case @opcode
    when :inp
      alu.registers[@params.first] = inputs.next
    when :add
      alu.registers[@params.first] = alu.registers[@params.first] + other[]
    when :mul
      alu.registers[@params.first] = alu.registers[@params.first] * other[]
    when :div
      alu.registers[@params.first] = alu.registers[@params.first] / other[]
    when :mod
      alu.registers[@params.first] = alu.registers[@params.first] % other[]
    when :eql
      alu.registers[@params.first] = alu.registers[@params.first] == other[] ? 1 : 0
    end
  end

  def reads?
    @opcode == :inp
  end

  def self.parse(line, alu)
    second_param = lambda do
      param = Regexp.last_match(2)
      param =~ /([-\d]+)/ ? param.to_i : param.to_sym
    end

    opcode, params = case line
                     when /inp (\w+)/
                       [:inp, [:"#{Regexp.last_match(1)}"]]
                     when /add (\w+) ([-\w]+)/
                       [:add, [Regexp.last_match(1).to_sym, second_param[]]]
                     when /mul (\w+) ([-\w]+)/
                       [:mul, [Regexp.last_match(1).to_sym, second_param[]]]
                     when /div (\w+) ([-\w]+)/
                       [:div, [Regexp.last_match(1).to_sym, second_param[]]]
                     when /mod (\w+) ([-\w]+)/
                       [:mod, [Regexp.last_match(1).to_sym, second_param[]]]
                     when /eql (\w+) ([-\w]+)/
                       [:eql, [Regexp.last_match(1).to_sym, second_param[]]]
                     else
                       puts "couldn't match line to instruction: '#{line}'"
                     end

    Instruction.new(opcode, *params)
  end
end

class ReferenceALU
  attr_accessor :program, :registers, :solutions

  def initialize(program)
    @program = program.dup
    @solutions = {}

    reset
  end

  def reset
    @registers = { w: 0, x: 0, y: 0, z: 0 }
  end

  def self.parse_program(data)
    program = []

    lines = data.chomp.split("\n")
    lines.each do |line|
      program << Instruction.parse(line, self)
    end

    ReferenceALU.new(program)
  end

  def run(original_inputs)
    inputs = Enumerator.new do |yielder|
      original_inputs.each do |input|
        yielder << input
      end
    end

    @program.each_with_index do |instruction, index|
      key = [@registers.dup, index]

      if @solutions[key].nil?
        instruction.execute(self, inputs)
        @solutions[key] = @registers.dup
      else
        @registers = @solutions[key]
        next
      end
    end
  end
end

# alu = ReferenceALU.parse_program(data)
# input = [9] * 14

# def decrement(input)
#   13.downto(0).each do |i|
#     take_more = false

#     input[i] -= 1
#     if input[i] == 0
#       input[i] = 9
#       take_more = true
#     end

#     break unless take_more
#   end
# end

# loop do
#   alu.reset
#   alu.run(input)
#   decrement(input)
# end while alu.registers[:w].zero?

# p input.map(&:to_s).join

# ============================
# end reference implementation
# ============================

class ALU
  attr_reader :solutions

  def initialize(a, b, c)
    @a = a
    @b = b
    @c = c

    @thresholds = (0..(a.length - 1)).map do |n|
      # the array a consists of only 26s and 1s, we divide z by this number at each iteration
      # thus, if we exceed the product of the values beyond the current index, we cannot reduce
      # to 0 and we know we can bail early
      a[n..].product
    end

    @values = (1..9).to_a

    @solutions = {}
  end

  def self.parse_program(data)
    a = []
    b = []
    c = []

    lines = data.chomp.split("\n")
    lines.each_with_index do |line, index|
      case line
      when /div z ([-\d]+)/
        a << Regexp.last_match(1).to_i
      when /add x ([-\d]+)/
        b << Regexp.last_match(1).to_i
      when /add y ([-\d]+)/
        c << Regexp.last_match(1).to_i if index % 18 == 15
      end
    end

    ALU.new(a, b, c)
  end

  def update(n, w, z)
    x = @b[n] + z % 26
    z /= @a[n]
    unless x == w
      z *= 26
      z += w + @c[n]
    end
    z
  end

  def run(n, z)
    key = [n, z]
    return @solutions[key] if @solutions[key]

    if n > 13
      return z.zero? ? [[]] : []
    end

    return [] if z > @thresholds[n]

    results = []
    @values.each do |w|
      next_z = update(n, w, z)
      next_results = run(n + 1, next_z)
      next_results.each do |next_result|
        results << [w] + next_result
      end
    end

    @solutions[key] = results
    results
  end
end

alu = ALU.parse_program(data)

results = alu.run(0, 0)
results.map!(&:concatenate)
p results.max
p results.min
