#!env ruby

require 'pp'
require './screen'

data = <<EOT
EOT

data = File.read(ARGV[0])

screen = Screen.new
screen.fill_from_text(data)

lines = data.chomp.split("\n")
