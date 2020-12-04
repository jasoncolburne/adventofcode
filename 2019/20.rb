#!env ruby

# this solution is incomplete, never got around to solving it after i read some other solutions

require 'pp'
require './graph'
require './screen'

data = <<EOT
         A           
         A           
  #######.#########  
  #######.........#  
  #######.#######.#  
  #######.#######.#  
  #######.#######.#  
  #####  B    ###.#  
BC...##  C    ###.#  
  ##.##       ###.#  
  ##...DE  F  ###.#  
  #####    G  ###.#  
  #########.#####.#  
DE..#######...###.#  
  #.#########.###.#  
FG..#########.....#  
  ###########.#####  
             Z       
             Z       
EOT

data = <<EOT
                   A               
                   A               
  #################.#############  
  #.#...#...................#.#.#  
  #.#.#.###.###.###.#########.#.#  
  #.#.#.......#...#.....#.#.#...#  
  #.#########.###.#####.#.#.###.#  
  #.............#.#.....#.......#  
  ###.###########.###.#####.#.#.#  
  #.....#        A   C    #.#.#.#  
  #######        S   P    #####.#  
  #.#...#                 #......VT
  #.#.#.#                 #.#####  
  #...#.#               YN....#.#  
  #.###.#                 #####.#  
DI....#.#                 #.....#  
  #####.#                 #.###.#  
ZZ......#               QG....#..AS
  ###.###                 #######  
JO..#.#.#                 #.....#  
  #.#.#.#                 ###.#.#  
  #...#..DI             BU....#..LF
  #####.#                 #.#####  
YN......#               VT..#....QG
  #.###.#                 #.###.#  
  #.#...#                 #.....#  
  ###.###    J L     J    #.#.###  
  #.....#    O F     P    #.#...#  
  #.###.#####.#.#####.#####.###.#  
  #...#.#.#...#.....#.....#.#...#  
  #.#####.###.###.#.#.#########.#  
  #...#.#.....#...#.#.#.#.....#.#  
  #.###.#####.###.###.#.#.#######  
  #.#.........#...#.............#  
  #########.###.###.#############  
           B   J   C               
           U   P   P               
EOT

data = <<EOT
             Z L X W       C                 
             Z P Q B       K                 
  ###########.#.#.#.#######.###############  
  #...#.......#.#.......#.#.......#.#.#...#  
  ###.#.#.#.#.#.#.#.###.#.#.#######.#.#.###  
  #.#...#.#.#...#.#.#...#...#...#.#.......#  
  #.###.#######.###.###.#.###.###.#.#######  
  #...#.......#.#...#...#.............#...#  
  #.#########.#######.#.#######.#######.###  
  #...#.#    F       R I       Z    #.#.#.#  
  #.###.#    D       E C       H    #.#.#.#  
  #.#...#                           #...#.#  
  #.###.#                           #.###.#  
  #.#....OA                       WB..#.#..ZH
  #.###.#                           #.#.#.#  
CJ......#                           #.....#  
  #######                           #######  
  #.#....CK                         #......IC
  #.###.#                           #.###.#  
  #.....#                           #...#.#  
  ###.###                           #.#.#.#  
XF....#.#                         RF..#.#.#  
  #####.#                           #######  
  #......CJ                       NM..#...#  
  ###.#.#                           #.###.#  
RE....#.#                           #......RF
  ###.###        X   X       L      #.#.#.#  
  #.....#        F   Q       P      #.#.#.#  
  ###.###########.###.#######.#########.###  
  #.....#...#.....#.......#...#.....#.#...#  
  #####.#.###.#######.#######.###.###.#.#.#  
  #.......#.......#.#.#.#.#...#...#...#.#.#  
  #####.###.#####.#.#.#.#.###.###.#.###.###  
  #.......#.....#.#...#...............#...#  
  #############.#.#.###.###################  
               A O F   N                     
               A A D   M                     
EOT

# data = File.read(ARGV[0])

def adjacent_cells(coordinates)
  x = coordinates[0]
  y = coordinates[1]
  [[x, y + 1], [x, y - 1], [x + 1, y], [x - 1, y]]
end

def bordering?(location, dimensions)
  location[0] < 5 || location[1] < 5 || location[0] > dimensions[0] - 5 || location[1] > dimensions[1] - 5
end

def determine_label(cells, components, dimensions)
  teleporter_location = cells.select { |cell| components[cell] == '.' }.first
  cells = cells.select { |cell| components[cell] =~ /[A-Z]/ }
  
  label = if cells[0][0] < cells[1][0] || cells[0][1] < cells[1][1]
    cells
  else
    cells.reverse
  end.map { |cell| components[cell] }.join('')

  if ['AA', 'ZZ'].include?(label)
    { label: label, location: teleporter_location }
  else
    suffix = bordering?(teleporter_location, dimensions) ? '2' : '1'
    { label: label + suffix, location: teleporter_location }
  end
end

def find_edges_v1(position, origin, path_tiles, graph, vertices_by_location, distance = 1, path = [])
  cells = adjacent_cells(position)
    .select { |cell| path_tiles.include?(cell) }
    .reject { |cell| path.include?(cell) }

  cells.each do |cell|
    if (label = vertices_by_location[cell])
      graph.add_edge(vertices_by_location[origin], label, distance)
    else
      path << position
      find_edges_v1(cell, origin, path_tiles, graph, vertices_by_location, distance + 1, path)
      path.pop
    end
  end
end

screen = Screen.new
screen.fill_from_text(data)
screen.display

letters_and_teleporters = []
handled_coordinates = {}
components = screen.find_matches(/[A-Z\.]/)
components.select { |coordinates, value| value =~ /[A-Z]/ }.each do |coordinates, value|
  next if handled_coordinates[coordinates]
  
  cells = adjacent_cells(coordinates).select { |other| components[other] }
  cells += adjacent_cells(cells.first).reject { |other| other == coordinates }.select { |other| components[other] } if cells.count < 2
  cells << coordinates

  letters_and_teleporters << determine_label(cells, components, screen.dimensions)

  cells.each { |cell| handled_coordinates[cell] = true }
end

vertices_by_location = {}
letters_and_teleporters.each do |aggregate|
  vertices_by_location[aggregate[:location]] = aggregate[:label]
end
vertices = letters_and_teleporters.map { |aggregate| aggregate[:label] }
graph = Graph.new(vertices)
path_tiles = screen.get_coordinates('.')
letters_and_teleporters.each do |aggregate|
  find_edges_v1(aggregate[:location], aggregate[:location], path_tiles, graph, vertices_by_location)
end

letters_and_teleporters.select { |aggregate| aggregate[:label] =~ /1$/ }.each do |aggregate|
  prefix = aggregate[:label][0..1]
  graph.add_edge(prefix + '1', prefix + '2', 1)
  graph.add_edge(prefix + '2', prefix + '1', 1)
end

# puts graph.best_path('AA', 'ZZ')
puts graph.best_recursive_path('AA', 'ZZ')
