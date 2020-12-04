require './graph'

# example taken from https://stackoverflow.com/questions/30409493/using-bfs-for-weighted-graphs
graph = Graph.new([1, 2, 3, 4, 5, 6])
graph.add_edge(1, 2, 7)
graph.add_edge(1, 3, 9)
graph.add_edge(1, 6, 14)
graph.add_edge(2, 3, 10)
graph.add_edge(2, 4, 15)
graph.add_edge(3, 4, 11)
graph.add_edge(3, 6, 2)
graph.add_edge(4, 5, 6)
graph.add_edge(6, 5, 9)

puts graph.dijkstra(1, 5) == 20 ? 'pass' : 'fail'