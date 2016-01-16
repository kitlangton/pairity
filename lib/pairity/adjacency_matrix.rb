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

    def people
      if @people.size.odd?
        @people.reject { |person| person.name == "Han Solo" }
      else
        @people
      end
    end

    def [](*args)
      @matrix[args.sort]
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

    def remove_person(person)
      @matrix.reject! do |pair, weight|
        pair.include?(person)
      end
      @people.delete(person)
    end

    def resistance(weight, pair)
      @matrix[pair.sort].resistance * weight
    end

    def add_weight_to_pair(weight, pair)
      @matrix[pair.sort].weight += resistance(weight, pair)
    end

    def add_day_to_pair(pair)
      @matrix[pair.sort].days += 1
    end
  end
end
