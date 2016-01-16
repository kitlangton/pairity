
module Pairity
  class PairRenderer
    def initialize(matrix)
      @matrix = matrix
    end

    def stats_for_pair(person1, person2)
      edge = @matrix[person1, person2]
      "paired #{Rainbow(edge.days).white} times."
    end
  end
end
