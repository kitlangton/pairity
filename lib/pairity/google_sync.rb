require 'pp'
require "google_drive"
require "ruby-progressbar"

ENV['SSL_CERT_FILE'] = Gem.loaded_specs['google-api-client'].full_gem_path+'/lib/cacerts.pem'

module Pairity
  class GoogleSync

    CONFIG_FILE = Dir.home + "/.pairity_google.json"

    attr_reader :sheet_url

    def initialize(matrix)
      @matrix = matrix
      @people = {}
      @sheet_url = nil
    end

    def load
      unless File.exists?(CONFIG_FILE)
        puts "Welcome, newcomer!"
        puts "Please follow these instructions to allow #{Rainbow("Pairity").white} to use Google Sheets to sync its precious data."
      end

      session = GoogleDrive.saved_session(CONFIG_FILE)

      puts "Loading Matrix from Google Sheets..."
      progressbar = ProgressBar.create(total: 100)

      progressbar.progress += 20
      sheet = session.spreadsheet_by_title("Pairity")
      unless sheet
        puts "Creating a new spreadsheet called: Pairity"
        sheet = session.create_spreadsheet("Pairity")
        sheet.add_worksheet("Days")
        sheet.add_worksheet("Resistance")
        sheet.add_worksheet("Weights")
        ws = sheet.worksheets[0]
        ws.title = "People"
        ws.save
      else
      end
      @sheet_url = sheet.worksheets[0].human_url

      ws = sheet.worksheets[0]

      # Add People and Tiers to Matrix
      ws.num_rows.times do |row|
        next unless row > 0
        name = ws[row + 1, 1]
        next if name.strip.empty?
        tier = ws[row + 1, 2]
        if name == "Han Solo"
          person = @matrix.han_solo
        else
          person = Person.new(name: name, tier: tier)
          @matrix.add_person(person)
        end
        @people[person] = row + 1
      end

      # Add data to edges
      (1..3).each do |i|
        ws = sheet.worksheets[i]
        @people.each do |p1, row|
          @people.each do |p2, col|
            next if p1 == p2
            data = ws[row, col]
            edit_edge(p1, p2, data, i)
          end
        end
      end

      @matrix
    end


    def clear_worksheet(ws)
      (1..ws.num_rows).each do |i|
        (1..ws.num_rows).each do |j|
          ws[i, j] = ""
          ws[j, i] = ""
        end
      end
    end

    def save
      puts "Saving Matrix to Google Sheets..."
      progressbar = ProgressBar.create(total: 100)

      session = GoogleDrive.saved_session(CONFIG_FILE)
      sheet = session.spreadsheet_by_title("Pairity")
      @people = @matrix.all_people.sort
      p @matrix.matrix

      progressbar.progress += 20

      ws = sheet.worksheets[0]

      clear_worksheet(ws)

      ws[1, 1] = "Name"
      ws[1, 2] = "Tier (1-3)"
      @people.each_with_index do |person, index|
        ws[index + 2, 1] = person.name
        ws[index + 2, 2] = person.tier
      end
      ws.save

      (1..3).each do |i|
        ws = sheet.worksheets[i]

        clear_worksheet(ws)

        @people.each_with_index do |person, index|
          ws[1, index + 2] = person.name
          ws[index + 2, 1] = person.name
        end

        progressbar.progress += 20
        @people.combination(2) do |pair|
          p1, p2 = pair
          index1 = @people.index(p1)
          index2 = @people.index(p2)
          edge = @matrix[p1,p2]
          case i
          when 1
            ws[1,1] = "Days"
            data = edge.days
          when 2
            ws[1,1] = "Resistances"
            data = edge.resistance
          when 3
            ws[1,1] = "Weights"
            data = edge.weight
          end
          ws[index1 + 2, index2 + 2] = data
          ws[index2 + 2, index1 + 2] = data
        end

        max = ws.max_rows

        @people.each_with_index do |person, index|
          ws[index + 2, index + 2] = ""
          ws[index + 2, index + 2] = ""
          max = index + 3
        end

        ws.save
      end
      progressbar.progress += 20

    end

    def edit_edge(p1, p2, data, i)
      case i
      when 1
        @matrix[p1, p2].days = data.to_i
      when 2
        @matrix[p1, p2].resistance = (data ? 1 : data.to_i)
      when 3
        @matrix[p1, p2].weight = data.to_i
      end
    end

    def find_person(name)

      person = @people.find { |person| person.name == name }

    end
  end
end
