require 'graph_matching'

g = GraphMatching::Graph::WeightedGraph[
  [1, 2, 10],
  [3, 2, 11],
  [1, 4, 11],
  [4, 5, 11]
]
m = g.maximum_weighted_matching(false)
p m.edges
p m.weight(g)
