require './heap'

class Vertex
  attr_accessor :name, :weight

  def initialize(name, weight = Float::INFINITY)
    @name = name
    @weight = weight
  end
end

class Graph
  def initialize(vertices)
    @vertices = vertices.map { |name| Vertex.new(name) }
    @graph = {}
    @min_distance = Float::INFINITY
  end

  # this kind of borks reusability, but it suited my use case here
  def add_edge(u, v, weight = 1)
    raise "unexpected vertices (#{u}, #{v})!" unless [u, v].all? { |vertex| @vertices.map(&:name).include?(vertex) }
    @graph[u] ||= []
    if old_data = @graph[u].find { |aggregate| aggregate[:vertex] == v }
      if old_data[:weight] > weight
        # keep the shorter path
        @graph[u].delete(old_data)
        @graph[u] << { vertex: v, weight: weight }
      end
    else    
      @graph[u] << { vertex: v, weight: weight }
    end
  end

  def edges_for(vertex)
    @graph[vertex]
  end

  def all_paths(origin, destination)
    visited = @vertices.zip([false] * @vertices.count).to_h
    paths = []
    collect_all_paths(origin, destination, visited, paths)
    paths
  end

  def best_path(origin, destination)
    all_paths(origin, destination).sort_by { |aggregate| aggregate[:distance] }.first
  end

  def recursive_paths(origin, destination)
    visited = {}
    visited[0] = @vertices.zip([false] * @vertices.count).to_h
    visited[-1] = @vertices.zip([true] * @vertices.count).to_h
    # in level 0 we must not use the outer portals
    visited[-1]['ZZ'] = false

    paths = []
    collect_all_recursive_paths(origin, destination, visited, paths)
    paths
  end

  def best_recursive_path(origin, destination)
    recursive_paths(origin, destination).sort_by { |aggregate| aggregate[:distance] }.first
  end

  private

  def collect_all_paths(origin, destination, visited, paths, path = [], distance = 0)
    return if distance >= @min_distance
    
    visited[origin] = true
    path << origin

    if origin == destination
      paths << { path: path.dup, distance: distance }
      @min_distance = distance
    else
      @graph[origin].each do |edge|
        collect_all_paths(edge[:vertex], destination, visited, paths, path, distance + edge[:weight]) unless visited[edge[:vertex]]
      end
    end

    path.pop
    visited[origin] = false
  end

  def dijkstra(origin, destination, distances = {})


  end

  def collect_all_recursive_paths(origin, destination, visited, paths, path = [], distance = 0, depth = 0)
    return if depth > @vertices.count / 2
    return if distance >= @min_distance

    visited[depth] ||= @vertices.zip([false] * @vertices.count).to_h   
    visited[depth][origin] = true
    path << origin

    if origin == destination && depth == 0
      paths << { path: path.dup, distance: distance }
      @min_distance = distance
      puts "Solutions: #{paths.count}, min_distance:#{@min_distance}"
    else
      @graph[origin].each do |edge|
        _depth = if origin[0..1] == edge[:vertex][0..1]
          origin.end_with?('1') ? depth + 1 : depth - 1
        else
          depth
        end
        collect_all_recursive_paths(edge[:vertex], destination, visited, paths, path, distance + edge[:weight], _depth) unless visited[_depth] && visited[_depth][edge[:vertex]]
      end
    end

    path.pop
    visited[depth][origin] = false
  end
end
