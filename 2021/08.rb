#!/usr/bin/env ruby

require 'set'

data = <<EOT
be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
EOT

data = File.read(ARGV[0])

input = data.chomp.split("\n")

def parse(input)
  input.map { |line| line.split(' | ').map(&:split) }
end

def solve(parsed_input, target_digits = [1, 4, 7, 8])
  count = 0
  sum = 0

  parsed_input.each do |signal_patterns, output_value|
    patterns_by_digit = {}
    wires_by_segment = {}

    signal_patterns.select { |pattern| [2, 3, 4, 7].include?(pattern.length) }.each do |pattern|
      pattern_set = pattern.chars.to_set

      case pattern_set.count
      when 2
        patterns_by_digit[1] = pattern_set
      when 3
        patterns_by_digit[7] = pattern_set
      when 4
        patterns_by_digit[4] = pattern_set
      when 7
        patterns_by_digit[8] = pattern_set
      end
    end
    
    wires_by_segment['a'] = patterns_by_digit[7] - patterns_by_digit[1]

    length_six_pattern_sets = signal_patterns.select { |pattern| pattern.length == 6 }.map { |pattern| pattern.chars.to_set }
    length_five_pattern_sets = signal_patterns.select { |pattern| pattern.length == 5 }.map { |pattern| pattern.chars.to_set }
    
    bfg = length_six_pattern_sets.inject(&:&) - wires_by_segment['a']
    dg = length_five_pattern_sets.inject(&:&) - wires_by_segment['a']

    wires_by_segment['g'] = dg & bfg
    wires_by_segment['d'] = dg - wires_by_segment['g']
    wires_by_segment['f'] = patterns_by_digit[1] & bfg
    wires_by_segment['c'] = patterns_by_digit[1] - wires_by_segment['f']
    wires_by_segment['b'] = bfg - wires_by_segment['f'] - wires_by_segment['g']
    wires_by_segment['e'] = patterns_by_digit[8] - wires_by_segment['a'] - wires_by_segment['b'] - wires_by_segment['c'] - wires_by_segment['d'] - wires_by_segment['f'] - wires_by_segment['g']

    patterns_by_digit[0] = wires_by_segment.values_at('a', 'b', 'c', 'e', 'f', 'g').inject(&:|)
    patterns_by_digit[2] = wires_by_segment.values_at('a', 'c', 'd', 'e', 'g').inject(&:|)
    patterns_by_digit[3] = wires_by_segment.values_at('a', 'c', 'd', 'f', 'g').inject(&:|)
    patterns_by_digit[5] = wires_by_segment.values_at('a', 'b', 'd', 'f', 'g').inject(&:|)
    patterns_by_digit[6] = wires_by_segment.values_at('a', 'b', 'd', 'e', 'f', 'g').inject(&:|)
    patterns_by_digit[9] = wires_by_segment.values_at('a', 'b', 'c', 'd', 'f', 'g').inject(&:|)

    target_sets = patterns_by_digit.values_at(*target_digits)
    count += output_value.map do |digit|
      target_sets.include?(digit.chars.to_set) ? 1 : 0
    end.sum

    sum += patterns_by_digit.key(output_value[0].chars.to_set) * 1000
    sum += patterns_by_digit.key(output_value[1].chars.to_set) * 100
    sum += patterns_by_digit.key(output_value[2].chars.to_set) * 10
    sum += patterns_by_digit.key(output_value[3].chars.to_set)
  end

  [count, sum]
end

puts solve(parse(input))
