module Pairity
  class PairPoster
    def initialize(pairs)
      @pairs = pairs
    end

    def generate_table
      solo_pair = @pairs.pop
      @pairs.shuffle!
      @pairs << solo_pair
      rows = @pairs.map.with_index do |(p1, p2), index|
        ["Room #{index+1}", p1,  p2]
      end
      Terminal::Table.new headings: ["Room","Driver","Navigator"], rows: rows
    end

    def post_to_slack
      Slackbot.new.post("```#{generate_table}```")
    end
  end
end
