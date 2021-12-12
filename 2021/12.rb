#!/usr/bin/env ruby

class Graph
  def initialize(vertices, labels_by_index)
    @vertices = vertices
    @labels_by_index = labels_by_index
    @adj = []
    vertices.times {  @adj << [] }
  end

  def add_edge(u, v)
    @adj[u] << v
  end

  def count_paths(origin, destination, allow_small_backtrack = false)
    @allow_small_backtrack = allow_small_backtrack
    visited = [0] * @vertices
    path_count = [0]
    count_paths_core(origin, destination, visited, path_count)
    path_count.first
  end

  def permitted?(i, visited)
    label = @labels_by_index[i]
    return false if label == 'start'
    return true if label.upcase == label
    return true if visited[i] == 0
    return true if !visited.include?(2) && @allow_small_backtrack
    false
  end

  def count_paths_core(u, d, visited, path_count)
    label = @labels_by_index[u]
    visited[u] += 1 unless label.upcase == label

    if u == d
      path_count[0] += 1
    else
      adjacent_vertices = @adj[u]
      adjacent_vertices.count.times do |i|
        count_paths_core(adjacent_vertices[i], d, visited, path_count) if permitted?(adjacent_vertices[i], visited)
      end
    end

    visited[u] -= 1
  end
end


data = <<EOT
start-A
start-b
A-c
A-b
b-d
A-end
b-end
EOT

data = File.read(ARGV[0])
input = data.chomp.split("\n")

i = 0
indicies_by_label = Hash.new do |h, k|
  h[k] = i
  i += 1
end

input.each do |pair|
  origin, destination = pair.split('-')
  indicies_by_label[origin]
  indicies_by_label[destination]
end

labels_by_index = {}
indicies_by_label.each do |k, v|
  labels_by_index[v] = k
end

graph = Graph.new(indicies_by_label.count, labels_by_index)

input.each do |pair|
  a, b = pair.split('-')
  graph.add_edge(indicies_by_label[a], indicies_by_label[b])
  graph.add_edge(indicies_by_label[b], indicies_by_label[a])
end

puts graph.count_paths(indicies_by_label['start'], indicies_by_label['end'])
puts graph.count_paths(indicies_by_label['start'], indicies_by_label['end'], true)
