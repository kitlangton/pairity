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

    def pairs_without_pair(pairs, given_pair)
      pairs.reject { |pair| given_pair.any? { |p| pair.include?(p)} }
    end

    def possible_pairs(array = [], pairs = [], peers = self.people.combination(2).to_a, count = self.people.size - 1)
      return array << pairs + peers if peers.size <= 1
      peers.first(count).each do |pair|
        possible_pairs(array, (pairs + [pair.sort]), (pairs_without_pair(peers, pair)), count - 2)
      end
      array
    end

    def branch_and_bound
      remaining_people = people.dup
      answer = []
      until remaining_people.empty?
        scores = []
        person = remaining_people[0]
        remaining_people.each do |other|
          next if other == person
          pair = [other, person].sort
          set = remaining_people - pair
          scores << {score: best_score(set, weight_for_pair(pair)), person: other}
        end
        # p scores.map { |score| "#{score[:score]} #{score[:person].name}" }
        min = scores.min_by { |score| score[:score] }
        pair = [min[:person], person].sort
        remaining_people -= pair
        answer << pair
      end
      answer
    end

    def best_score(set, score)
      total = score
      set.combination(2).to_a.inject(0) { |sum, pair| sum += weight_for_pair(pair) }
      set[0..-2].each_with_index do |person, i|
        scores = []
        (i+1...set.size).each do |j|
          other = set[j]
          next if person == other
          scores << self[person, other].weight
        end
        total += scores.min
      end
      total
    end

    def reasonable_combinations
      people.combination(2).to_a.reject { |pair| weight_for_pair(pair) > average_weight}
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
