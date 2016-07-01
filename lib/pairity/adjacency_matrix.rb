require 'graph_matching'

module Pairity
  class AdjacencyMatrix
    attr_accessor :matrix, :han_solo

    def initialize
      @han_solo = Person.new(name: "Han Solo")
      @people = [@han_solo]
      @matrix = {}
    end

    def to_s
      output = []
      matrix.each do |pair, weight|
        # next if pair.include?(@han_solo)
        output << "#{pair} -> #{weight}"
      end
      output.join("\n")
    end

    def people(solo = false)
      if @people.size.odd? || solo
        @people.reject { |person| person.name == "Han Solo" }
      else
        @people
      end
    end

    def matrix(solo = false)
      if @people.size.odd? || solo
        without_solo
      else
        @matrix
      end
    end

    def set_ids(persons)
      persons.each_with_index do |p, i|
        p.id = i+1
      end
    end

    def all_people
      @people
    end

    def without_solo
      @matrix.reject { |pair, edge| pair.include?(han_solo) }
    end

    def [](*args)
      @matrix[args.sort]
    end

    def []=(*args, edge)
      @matrix[args.sort] = edge
    end

    def weight_for_pairs(pairs)
      pairs.inject(0) do |sum, pair|
        sum += weight_for_pair(pair)
      end
    end

    def weight_for_pair(pair)
      @matrix[pair.sort].weight
    end

    def add_person(new_person)
      @people.each do |person|
        pair = [person, new_person].sort
        @matrix[pair] = Edge.new
      end
      @people << new_person
    end

    def average_weight
      people.combination(2).to_a.inject(0) do |sum, pair|
        sum += self[*pair].weight
      end / people.combination(2).size
    end

    def average_days
      people.combination(2).to_a.inject(0) do |sum, pair|
        sum += self[*pair].days
      end / people.combination(2).size
    end

    def get_pairs(pairs, first)
      return [] if pairs.empty?
      pairs.first(first).map do |pair|
        [pair, get_pairs(pairs_without_pair(pairs, pair), 1000).flatten]
      end
    end

    def find_person(id)
      @people.find { |p| p.id == id }
    end

    def optimal_pairs(nopes)
      set_ids(people)
      pairing_array = matrix.map do |pair, edge|
        next if nopes.include?(pair.sort)
        p1, p2 = pair
        ids = [p1.id, p2.id].sort
        [ids[0], ids[1], edge.weight * -1]
      end

      pairing_array.compact!

      g = GraphMatching::Graph::WeightedGraph[*pairing_array]
      m = g.maximum_weighted_matching(true)
      m.edges.map do |pair|
        [find_person(pair[0]), find_person(pair[1])]
      end
    end

    def remove_person(person)
      @matrix.reject! do |pair, weight|
        pair.include?(person)
      end
      @people.delete(person)
    end

    def resistance(weight, pair)
      tier_compensation = 0
      if pair.all?{ |p| p.tier == 1} || pair.all?{ |p| p.tier == 3}
        tier_compensation = 1.5
      end
      @matrix[pair.sort].resistance * weight + tier_compensation
    end

    def add_weight_to_pair(weight, pair)
      @matrix[pair.sort].weight += resistance(weight, pair)
    end

    def add_day_to_pair(pair)
      @matrix[pair.sort].days += 1
    end
  end
end
