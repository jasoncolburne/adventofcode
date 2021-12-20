#!/usr/bin/env ruby

require 'set'
require 'rubygems'
require 'bundler/setup'
require 'jason/math'

require './screen'

data = <<EOT
1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
EOT

data = File.read(ARGV[0])

screen = Screen.new
screen.fill_from_text_as_integers(data)

expanded = false
2.times do
  graph = Jason::Math::GraphTheory::Graph.new(screen.display_buffer.keys)
  display_buffer = screen.display_buffer
  screen.display_buffer.each_key do |origin|
    origin.adjacent_cells.each do |destination|
      value = display_buffer[destination]
      graph.add_edge(origin, destination, value) if value
    end
  end

  puts graph.dijkstra([0, 0], [screen.x_max, screen.y_max])

  screen.aoc_five_by_five! unless expanded
  expanded = true
end
