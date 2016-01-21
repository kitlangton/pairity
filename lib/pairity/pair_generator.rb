require 'byebug'

module Pairity
  class PairGenerator

    @@shuffle = false

    attr_reader :pairs, :last_pairs

    def self.shuffle=(toggle)
      @@shuffle = toggle
    end

    def initialize(matrix)
      @matrix = matrix
      @last_pairs = []
      @pairs = []
      @nopes = []
    end

    def generate_pairs
      @pairs = []
      # @pairs = possible_pairs.min_by { |pairs| @matrix.weight_for_pairs(pairs) }
      # @pairs.map! { |pair| pair.sort }.sort_by! { |pair| pair[0] }
      @pairs = @matrix.branch_and_bound
      move_solo_to_the_end
      @pairs
    end

    def old_pairs
      pairs = possible_pairs.min_by { |pairs| @matrix.weight_for_pairs(pairs) }
      pairs.map! { |pair| pair.sort }.sort_by! { |pair| pair[0] }
    end

    def branch_pairs
      @matrix.branch_and_bound
    end

    def possible_pairs
      @matrix.possible_pairs.reject { |pairing| pairing.any? { |pair| @nopes.include?(pair) }}
    end

    def move_solo_to_the_end
      solo = @pairs.find { |pair| pair.any? { |person| person.name == "Han Solo" } }
      return @pairs unless solo
      index = @pairs.index(solo)
      @pairs[index], @pairs[-1] = @pairs[-1], @pairs[index]
      @pairs
    end

    def nope(p1,p2)
      pair = [p1, p2].sort
      @nopes << pair
    end

    def save_pairs
      @pairs.each do |pair|
        @matrix.add_weight_to_pair(1, pair)
        @matrix.add_day_to_pair(pair)
      end
      @nopes = []
      @last_pairs = @pairs
    end

    def revert
      @pairs = @last_pairs
    end

    def days_for_pair(person1, person2)
      @matrix[person1, person2].days
    end

    def abolish_pairing(person1, person2)
      @matrix.add_weight_to_pair(1_000_000,[person1,person2].sort)
    end

    def resistance(person1, person2, resistance)
      @matrix[person1, person2].resistance = resistance
    end

    def equilibrium
      @matrix.people.combination(2).to_a.size / (@matrix.people.size / 2)
    end

    def include?(person1, person2)
      @pairs.any? { |pair| pair == [person1, person2].sort }
    end
  end
end
