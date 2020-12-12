#!/usr/bin/env ruby

require 'pp'
require 'set'
require './screen'

data = <<EOT
EOT

# data = File.read(ARGV[0])

lines = data.chomp.split("\n")
