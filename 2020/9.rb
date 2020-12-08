#!/usr/bin/env ruby

require 'set'
require 'pp'

data = <<EOT
EOT

data = File.read(ARGV[0])

lines = data.chomp.split("\n")
