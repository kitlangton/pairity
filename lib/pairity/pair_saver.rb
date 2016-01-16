module Pairity
  class PairSaver
    def initialize(pairs)
      @pairs = pairs
    end

    def post_to_slack
      rows = []
      @pairs.each_with_index do |pair, index|
        col = []
        col << "Room ##{index+1}"
        col << pair[0]
        col << pair[1]
        rows << col
      end
      table = Terminal::Table.new headings: ["Room","Driver","Navigator"], rows: rows
      Slackbot.new.post("```#{table.to_s}```")
    end
  end
end
