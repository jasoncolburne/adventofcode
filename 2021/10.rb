#!/usr/bin/env ruby

data = <<EOT
[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]
EOT

data = File.read(ARGV[0])

input = data.chomp.split("\n")

$ERROR_SCORES = {
  ')' => 3,
  ']' => 57,
  '}' => 1197,
  '>' => 25137,
}

$CLOSING_BRACKETS = {
  '(' => ')',
  '[' => ']',
  '{' => '}',
  '<' => '>',
}

def syntax_error_score(line)
  stack = []
  line.each_char do |character|
    if $CLOSING_BRACKETS.keys.include?(character)
      stack << $CLOSING_BRACKETS[character]
    else
      if stack.count > 0 && stack.last == character
        stack.pop
      else
        return $ERROR_SCORES[character]
      end
    end
  end
  0
end

def total_error_score(data)
  data.map { |line| syntax_error_score(line) }.sum
end

def missing_closing_brackets(line)
  stack = []
  closing_brackets = []

  line.each_char do |character|
    if $CLOSING_BRACKETS.keys.include?(character)
      stack << $CLOSING_BRACKETS[character]
    elsif stack.count > 0 && stack.last == character
      stack.pop
    end
  end
  
  stack.reverse
end


$CONTEST_SCORES = {
  ')' => 1,
  ']' => 2,
  '}' => 3,
  '>' => 4,
}

pp total_error_score(input)
scores = input.reject { |line| syntax_error_score(line) > 0 }.map { |line| missing_closing_brackets(line) }.map do |brackets|
  score = 0
  
  brackets.each do |bracket|
    score *= 5
    score += $CONTEST_SCORES[bracket]
  end
  
  score
end.sort

pp scores[scores.count / 2]
