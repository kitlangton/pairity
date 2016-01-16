module Pairity

  class Edge
    attr_accessor :weight, :days, :resistance

    def initialize(weight: 0, days: 0, resistance: 1)
      @weight = weight
      @days = days
      @resistance = resistance
    end

    def to_s
      "Weight: #{weight} Days: #{days}"
    end
  end

end
