#!env ruby

require 'pp'
require './computer'
require './screen'

class Game
  attr_reader :score

  def initialize(display = true, debug = false)
    @program = eval("[" + File.read(ARGV[0]) + "]")
    @display = display
    @computer = Computer.new(debug)
    @screen = Screen.new
    @display_buffer = {}
    @score = 0
  end

  def insert_quarters
    @program[0] = 2
  end

  def play_until_halted
    context = @computer.load_program('Main', @program)
    outputs = context.outputs
    paddle_x_position = 22
    ball_x_position = 20

    while !@computer.halted?
      @computer.step until @computer.halted? || outputs.size == 3 || context.blocked?

      if context.blocked?
        input = if paddle_x_position > ball_x_position
          -1
        elsif paddle_x_position < ball_x_position
          1
        else # ==
          0
        end

        context.inputs << input

        if @display
          sleep(0.04)
          @screen.display(true)
          puts "Score: #{@score}"
        end

        # kickstart computer
        @computer.step
      elsif outputs.size == 3
        x = outputs.shift
        y = outputs.shift
        value = outputs.shift
  
        coordinates = [x, y]
  
        if coordinates == [-1, 0]
          @score = value
        else
          character = case value
          when 0
            ' '
          when 1
            '█'
          when 2
            '='
          when 3
            puts "paddle_position: #{x}"
            paddle_x_position = x
            '-'
          when 4
            puts "ball_position: #{x}"
            ball_x_position = x
            'o'
          else
            raise "unexpected value!"
          end
          
          @screen[coordinates] = character
        end  
      end
    end
  end
end

game = Game.new
game.insert_quarters
game.play_until_halted
puts game.score

