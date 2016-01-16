module Pairity
  class Person
    attr_accessor :name, :tier

    def initialize(name:, tier: 2)
      @name = name
      @tier = !((1..3) === tier) ? 2 : tier
    end

    def <=>(other_person)
      return -1 if name == "Han Solo"
      return 1 if other_person.name == "Han Solo"
      name <=> other_person.name
    end

    def to_s
      "#{name}"
    end
  end
end
