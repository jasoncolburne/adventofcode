class ExecutionContext
  OPCODE_ADD                  = 1
  OPCODE_MULTIPLY             = 2
  OPCODE_INPUT                = 3
  OPCODE_OUTPUT               = 4
  OPCODE_JUMP_IF_TRUE         = 5
  OPCODE_JUMP_IF_FALSE        = 6
  OPCODE_LESS_THAN            = 7
  OPCODE_EQUALS               = 8
  OPCODE_ADJUST_RELATIVE_BASE = 9
  OPCODE_HALT                 = 99

  attr_reader :name, :done
  attr_accessor :inputs, :outputs, :debug

  def initialize(name, program, inputs = [], debug = false, memory = 10000)
    @name = name
    @program = program.dup + [0] * memory
    @inputs = inputs
    @debug = debug
    @done = false
    @blocked = false
    @outputs = []
    @ip = 0
    @rb = 0
  end

  def receive_ascii(ascii)
    @inputs += ascii.bytes
  end

  def output_as_ascii
    outputs = @outputs
    @outputs = []
    outputs.map(&:chr).join('')
  end

  def blocked?
    @blocked
  end

  def params_string(i, j, k, mi, mj, mk)
    return "" unless i # || j || k

    [[i, mi], [j, mj], [k, mk]].map do |param, mode|
      if param
        (mode == 2 ? '*' : '') + ([0,2].include?(mode) ? '[' : '') + param.to_s + ([0,2].include?(mode) ? ']' : '')
      else
        nil
      end
    end.compact.join(', ')
  end

  def values_string(i, j, k)
    return "" unless i # || j || k

    [i, j, k].compact.map { |index| @program[index] }.map(&:to_s).join(', ')
  end

  def print_instruction(instruction, i: nil, j: nil, k: nil, mi: nil, mj: nil, mk: nil)
    puts "#{@name}@#{@ip.to_s.rjust(5, '0')}: #{instruction.ljust(3, ' ')} #{params_string(i, j, k, mi, mj, mk)} (#{values_string(i, j, k)})" if @debug
  end

  def offset_by_mode(mode, offset)
    case mode
    when 0
      @program[@ip + offset]
    when 1
      @ip + offset
    when 2
      @rb + @program[@ip + offset]
    else
      raise "unknown mode!"
    end
  end

  def step
    return if done

    instruction = @program[@ip]

    opcode = instruction % 100
    instruction /= 100
    mode1 = instruction % 10
    instruction /= 10
    mode2 = instruction % 10
    instruction /= 10
    mode3 = instruction % 10

    i = nil
    j = nil
    k = nil

    case opcode
    when OPCODE_HALT
    when OPCODE_INPUT, OPCODE_OUTPUT, OPCODE_ADJUST_RELATIVE_BASE
      i = offset_by_mode(mode1, 1)
    when OPCODE_JUMP_IF_TRUE, OPCODE_JUMP_IF_FALSE
      i = offset_by_mode(mode1, 1)
      j = offset_by_mode(mode2, 2)
    when OPCODE_ADD, OPCODE_MULTIPLY, OPCODE_LESS_THAN, OPCODE_EQUALS
      i = offset_by_mode(mode1, 1)
      j = offset_by_mode(mode2, 2)
      k = offset_by_mode(mode3, 3)
    else
      raise "unknown opcode (#{opcode})!"
    end

    case opcode
    when OPCODE_ADD
      print_instruction('ADD', i: i, j: j, k: k, mi: mode1, mj: mode2, mk: mode3)
      @program[k] = @program[i] + @program[j]
      @ip += 4
    when OPCODE_MULTIPLY
      print_instruction('MUL', i: i, j: j, k: k, mi: mode1, mj: mode2, mk: mode3)
      @program[k] = @program[i] * @program[j]
      @ip += 4
    when OPCODE_INPUT
      print_instruction('IN', i: i, mi: mode1)
      input = @inputs.shift
      # if input is nil, block and try again on the next step
      unless input.nil?
        @program[i] = input
        @ip += 2
        @blocked = false
      else
        @blocked = true
      end
    when OPCODE_OUTPUT
      print_instruction('OUT', i: i, mi: mode1)
      @outputs << @program[i]
      @ip += 2
    when OPCODE_JUMP_IF_TRUE
      print_instruction('JNZ', i: i, j: j, mi: mode1, mj: mode2)
      unless @program[i].zero?
          @ip = @program[j]
      else
          @ip += 3
      end
    when OPCODE_JUMP_IF_FALSE
      print_instruction('JZ', i: i, j: j, mi: mode1, mj: mode2)
      if @program[i].zero?
          @ip = @program[j]
      else
          @ip += 3
      end
    when OPCODE_LESS_THAN
      print_instruction('LT', i: i, j: j, k: k, mi: mode1, mj: mode2, mk: mode3)
      @program[k] = @program[i] < @program[j] ? 1 : 0
      @ip += 4
    when OPCODE_EQUALS
      print_instruction('EQ', i: i, j: j, k: k, mi: mode1, mj: mode2, mk: mode3)
      @program[k] = @program[i] == @program[j] ? 1 : 0
      @ip += 4
    when OPCODE_ADJUST_RELATIVE_BASE
      print_instruction('ARB', i: i, mi: mode1)
      @rb += @program[i]
      @ip += 2
    when OPCODE_HALT
      print_instruction('HLT')
      @ip += 1
      @done = true
    else
      raise "unknown opcode (#{opcode})!"
    end
  end
end

class Computer
  attr_reader :execution_contexts

  def initialize(debug = false)
    @debug = debug
    @current_context = 0
    @execution_contexts = []
    @redirections = {}
  end

  def load_program(name, program, inputs = [])
    context = ExecutionContext.new(name, program, inputs, @debug)
    @execution_contexts << context
    context
  end

  def execute_until_all_contexts_are_done
    step while !halted?
  end

  def execute_until_all_contexts_blocked
    step while !all_blocked?
  end

  def execute_until_halted_or_blocked!
    step while !halted? && !all_blocked?
  end

  def execute_until_network_output!
    step until any_network?
  end

  def execute_until_io!
    step until any_network? || any_blocked?
  end

  def step
    context = @execution_contexts[@current_context]
    context.step
    if @redirections[context.name]
      output = context.outputs.shift
      @redirections[context.name].map { |consumer_name| find_context(consumer_name) }.each{ |context| context.inputs << output } if output
    end
    @current_context = (@current_context + 1) % @execution_contexts.count
  end

  def step_all
    @execution_contexts.count.times { step }
  end

  def all_blocked?
    @execution_contexts.all?(&:blocked?)
  end

  def any_blocked?
    @execution_contexts.any?(&:blocked?)
  end

  def halted?
    @execution_contexts.all?(&:done)
  end

  def any_network?
    @execution_contexts.any? { |context| context.outputs.count >= 3 }
  end

  def find_context(name)
    @execution_contexts.find { |context| context.name == name }
  end

  def redirect(producer, consumer)
    @redirections[producer] ||= []
    @redirections[producer] << consumer
  end
end
