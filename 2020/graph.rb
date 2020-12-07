require 'rb_heap'

class Graph
  def initialize(vertices)
    @vertices = vertices
    @graph = {}
  end

  def add_edge(origin, destination, weight = 1)
    raise "unexpected vertices (#{origin}, #{destination})!" unless [origin, destination].all? { |vertex| @vertices.include?(vertex) }

    @graph[origin] ||= []
    if old_data = edge_from(origin, destination)
      if old_data[:weight] > weight
        # update to the shorter path
        @graph[origin].delete(old_data)
        @graph[origin] << { vertex: destination, weight: weight }
      end
    else    
      @graph[origin] << { vertex: destination, weight: weight }
    end
  end

  def edges_for(vertex)
    @graph[vertex] ||= []
  end

  def edge_from(origin, destination)
    @graph[origin].find { |edge| edge[:vertex] == destination }
  end

  def dijkstra(origin, destination)
    distances = (@vertices - [origin]).zip([Float::INFINITY] * (@vertices.count - 1)).to_h
    distances[origin] = 0

    heap = Heap.new { |a, b| distances[a] < distances[b] }
    heap << origin

    until heap.empty? do
      vertex = heap.pop
      edges_for(vertex).each do |edge|
        if distances[edge[:vertex]] > distances[vertex] + edge[:weight]
          distances[edge[:vertex]] = distances[vertex] + edge[:weight]
          heap << edge[:vertex]
        end
      end
    end

    distances[destination]
  end
end