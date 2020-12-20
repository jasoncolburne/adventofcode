#!/usr/bin/env ruby

require 'set'

data = <<EOT
0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"

ababbb
bababa
abbbab
aaabbb
aaaabbb
EOT

data = <<EOT
42: 9 14 | 10 1
9: 14 27 | 1 26
10: 23 14 | 28 1
1: "a"
11: 42 31
5: 1 14 | 15 1
19: 14 1 | 14 14
12: 24 14 | 19 1
16: 15 1 | 14 14
31: 14 17 | 1 13
6: 14 14 | 1 14
2: 1 24 | 14 4
0: 8 11
13: 14 3 | 1 12
15: 1 | 14
17: 14 2 | 1 7
23: 25 1 | 22 14
28: 16 1
4: 1 1
20: 14 14 | 1 15
3: 5 14 | 16 1
27: 1 6 | 14 18
14: "b"
21: 14 1 | 1 14
25: 1 1 | 1 14
22: 14 14
8: 42
26: 14 22 | 1 20
18: 15 15
7: 14 5 | 1 21
24: 14 1

abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
bbabbbbaabaabba
babbbbaabbbbbabbbbbbaabaaabaaa
aaabbbbbbaaaabaababaabababbabaaabbababababaaa
bbbbbbbaaaabbbbaaabbabaaa
bbbababbbbaaaaaaaabbababaaababaabab
ababaaaaaabaaab
ababaaaaabbbaba
baabbaaaabbaaaababbaababb
abbbbabbbbaaaababbbbbbaaaababb
aaaaabbaabaaaaababaa
aaaabbaaaabbaaa
aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
babaaabbbaaabaababbaabababaaab
aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")

rules = {}

i = 0
until lines[i].empty?
  lines[i] =~ /^(\d+): (.*)$/
  number = $1.to_i
  value = $2.gsub('"', '')

  if value =~ /^\d/
    if value =~ /\|/
      value = value.split('|').map(&:strip).map { |v| v.split(' ').map(&:to_i) }
    else
      value = [value.split(' ').map(&:to_i)]
    end
  end

  rules[number] = value
  i += 1
end
i += 1

def each_match_sequence(rules, string, sequence, string_index, sequence_index = 0)
  if sequence_index == sequence.count
    yield string_index
  else
    each_match(rules, string, sequence[sequence_index], string_index) do |string_index_2|
      each_match_sequence(rules, string, sequence, string_index_2, sequence_index + 1) do |string_index_3|
        yield string_index_3
      end
    end
  end
end

def each_match(rules, string, rule_index, string_index = 0)
  if rules[rule_index].is_a?(String)
    # we found a viable path, so continue
    yield string_index + 1 if string[string_index] == rules[rule_index]
  else
    rules[rule_index].each do |sequence|
      each_match_sequence(rules, string, sequence, string_index) do |string_index_2|
        yield string_index_2
      end
    end
  end
end

def match(rules, string, matches)
  each_match(rules, string, 0) do |matched_character_count|
    matches << string if matched_character_count == string.length
  end
end

def count_matches(rules, input)
  matches = Set[]

  input.each do |line|
    match(rules, line, matches)
  end

  matches.count
end

input = lines[i..]

puts count_matches(rules, input)

rules[8] = [[42], [42, 8]]
rules[11] = [[42, 31], [42, 11, 31]]

puts count_matches(rules, input)
