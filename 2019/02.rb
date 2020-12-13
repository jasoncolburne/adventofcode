#!/usr/bin/env ruby

require 'pp'

TEST_VECTORS = [
    [1,0,0,0,99], # becomes 2,0,0,0,99 (1 + 1 = 2).
    [2,3,0,3,99], # becomes 2,3,0,6,99 (3 * 2 = 6).
    [2,4,4,5,99,0], # becomes 2,4,4,5,99,9801 (99 * 99 = 9801).
    [1,1,1,4,99,5,6,0,99], # becomes 30,1,1,4,2,5,6,0,99
]

OPCODE_ADD = 1
OPCODE_MULTIPLY = 2

def compute(program, replace = false, debug = false)
    ip = 0

    program = program.dup unless replace
    while program[ip] != 99
        i = program[ip + 1]
        j = program[ip + 2]
        k = program[ip + 3]

        case program[ip]
        when OPCODE_ADD
            # program[k] = program[i] + program[j]
            puts "ADD [#{i}], [#{j}], [#{k}]" if debug
            program[k] = program[i] + program[j]
        when OPCODE_MULTIPLY
            puts "MUL [#{i}], [#{j}], [#{k}]" if debug
            program[k] = program[i] * program[j]
        else
            raise "unknown opcode!"
        end
        ip += 4
    end

    program
end

# pp TEST_VECTORS.map { |vector| compute(vector) }
# pp TEST_VECTORS

def run_program(noun, verb, debug = false)
    data = "[" + File.read(ARGV.first) + "]"
    program = eval(data)
    program[1] = noun
    program[2] = verb
    puts "Running program with inputs #{noun}, #{verb}" if debug
    compute(program, false, debug)
end

(1..100).each do |noun|
    (1..100).each do |verb|
        result = run_program(noun, verb)[0]
        if result == 19690720
            puts 100 * noun + verb
            exit
        end
    end
end
