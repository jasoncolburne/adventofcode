#!env ruby

require 'pp'
require 'set'
require './screen'

data = <<EOT
#########
#b.A.@.a#
#########
EOT

data = <<EOT
########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################
EOT

data = <<EOT
########################
#...............b.C.D.f#
#.######################
#.....@.a.B.c.d.A.e.F.g#
########################
EOT

data = <<EOT
#################
#i.G..c...e..H.p#
########.########
#j.A..b...f..D.o#
########@########
#k.E..a...g..B.n#
########.########
#l.F..d...h..C.m#
#################
EOT

# data = <<EOT
# ########################
# #@..............ac.GI.b#
# ###d#e#f################
# ###A#B#C################
# ###g#h#i################
# ########################
# EOT

data = File.read(ARGV[0])

class Graph
  def initialize(vertices)
    @vertices = vertices
    @graph = {}
  end

  # this kind of borks reusability, but it suited my use case here
  def add_edge(u, v, weight = 1, doors = [])
    raise "unexpected vertex (#{u}, #{v})!" unless [u, v].all? { |vertex| @vertices.include?(vertex) }
    @graph[u] ||= []
    if old_data = @graph[u].find { |aggregate| aggregate[:vertex] == v }
      if old_data[:weight] > weight
        # keep the shorter path
        @graph[u].delete(old_data)
        @graph[u] << { vertex: v, weight: weight, doors: doors }
      end
    else    
      @graph[u] << { vertex: v, weight: weight, doors: doors }
    end
  end

  def edges_for(vertex)
    @graph[vertex]
  end

  def count_collections
    @graph.count
  end
end

class Cave
  def initialize(data, debug = false, correct_entrance = false)
    @screen = Screen.new.fill_from_text(data)
    @coordinates_by_vertex = {}

    if correct_entrance
      update_map_entrance
      starting_points = ['1', '2', '3', '4']
    else
      starting_points = ['@']
    end

    (('a'..'z').to_a + starting_points).each do |character|
      coordinates = @screen.get_coordinates(character)
      raise "unexpected data found in input!" if coordinates.size > 1
      @coordinates_by_vertex[character] = coordinates.first unless coordinates.empty?
    end

    @path_cells = @screen.get_coordinates('.') + (('A'..'Z').to_a + ('a'..'z').to_a + starting_points).map do |value|
      coordinates = @screen.get_coordinates(value)
      coordinates.empty? ? nil : coordinates.first
    end.compact

    @graph = Graph.new(@coordinates_by_vertex.keys)
    build_edges

    @steps_taken_by_keys = {}
    @debug = debug
  end

  def determine_minimum_steps_to_collect_all_keys
    @screen.get_coordinates('@').count == 0 ? quad_walk(['1', '2', '3', '4']) : walk('@')
  end

  def update_map_entrance
    position = @screen.get_coordinates('@').first
    @screen[position] = '#'
    adjacent_cells(position).each { |coordinates| @screen[coordinates] = '#' }
    x = position[0]
    y = position[1]
    @screen[[x + 1, y + 1]] = '1'
    @screen[[x - 1, y + 1]] = '2'
    @screen[[x + 1, y - 1]] = '3'
    @screen[[x - 1, y - 1]] = '4'
  end

  private

  def walk(key, keys = [])
    return 0 if keys.count >= @coordinates_by_vertex.count - 1

    keys.sort!
    return @steps_taken_by_keys[[key, keys]] if @steps_taken_by_keys.member?([key, keys])

    result = @graph.edges_for(key)
                  .reject { |edge| keys.include?(edge[:vertex]) }
                  .select { |edge| edge[:doors].all? { |door| keys.include?(door.downcase) } }
                  .map do |edge|
                    _key = edge[:vertex]
                    _keys = (_key == '@' ? keys : keys + [_key])
                    n = walk(_key, _keys)
                    n && n + edge[:weight]
                  end.compact.min
    @steps_taken_by_keys[[key, keys]] = result
    result
  end

  def quad_walk(keys, collected = [])
    return 0 if collected.count >= @coordinates_by_vertex.count - 4

    keys.sort!
    collected.sort!
    return @steps_taken_by_keys[[keys, collected]] if @steps_taken_by_keys.member?([keys, collected])

    l = []
    keys.each_with_index do |key, index|
      l << @graph.edges_for(key)
                  .reject { |edge| collected.include?(edge[:vertex]) }
                  .select { |edge| edge[:doors].all? { |door| collected.include?(door.downcase) } }
                  .map do |edge|
                    _key = edge[:vertex]
                    _keys = keys.dup
                    _keys[index] = _key
                    _collected = (['1', '2', '3', '4'].include?(_key) ? collected : collected + [_key])
                    n = quad_walk(_keys, _collected)
                    n && n + edge[:weight]
                  end.compact.min
    end
    result = l.compact.min
    @steps_taken_by_keys[[keys, collected]] = result
    result
  end


  def build_edges
    @started_collecting_at = Time.now
    @coordinates_by_vertex.values.each { |origin| find_edges(origin, origin) }
  end

  def adjacent_cells(coordinates)
    x = coordinates[0]
    y = coordinates[1]
    [[x, y + 1], [x, y - 1], [x + 1, y], [x - 1, y]]
  end

  def find_edges(position, origin)
    d = {}
    seen = Set.new([position])
    boundary = { position => [] }
    n = 0
    loop do
      n += 1
      next_boundary = {}
      boundary.each do |coordinates, doors|
        adjacent_cells(coordinates).each do |_position|
          value = @screen[_position]
          if value != "#" && !seen.member?(_position)
            d[value] = { weight: n, doors: doors.dup } if is_key?(value)
            
            _doors = doors.dup
            if is_door?(value)
              _doors << value
              _doors.sort!
            end

            raise if next_boundary.fetch(_position, _doors) != _doors
            next_boundary[_position] = _doors
          end
        end
      end
      break if next_boundary.length == 0
      seen.merge(next_boundary.keys)
      boundary = next_boundary
    end
    d.each { |value, data| @graph.add_edge(@screen[origin], value, data[:weight], data[:doors]) }
  end

  def is_key?(value)
    x = value.ord - 'a'.ord
    x >= 0 && x < 26
  end

  def is_door?(value)
    x = value.ord - 'A'.ord
    x >= 0 && x < 26
  end
end

debug = false
# puts Cave.new(data, debug).determine_minimum_steps_to_collect_all_keys
puts Cave.new(data, debug, true).determine_minimum_steps_to_collect_all_keys