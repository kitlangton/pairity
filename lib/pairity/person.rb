module Pairity
  class Person
    attr_accessor :name

    def initialize(name: name) # !> circular argument reference - name
      @name = name
    end

    def <=>(other_person)
      name <=> other_person.name
    end

    def to_s
      "#{name}"
    end
  end
end
