require "google/api_client"
require "google_drive"
require "ruby-progressbar"

ENV['SSL_CERT_FILE'] = Gem.loaded_specs['google-api-client'].full_gem_path+'/lib/cacerts.pem'

module Pairity
  class GoogleSync

    CONFIG_FILE = Dir.home + "/.pairity_google.json"

    attr_reader :sheet_url

    def initialize(matrix)
      @matrix = matrix
      @people = []
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
      @sheet_url = sheet.worksheets[0].human_url
      unless sheet
        puts "Creating a new spreadsheet called: Pairity"
        sheet = session.create_spreadsheet("Pairity")
        sheet.add_worksheet("Days")
        sheet.add_worksheet("Resistance")
        ws = sheet.worksheets[0]
        ws.title = "Weights"
        ws.save
      else
      end

      (0..2).each do |i|
        progressbar.progress += 20

        @edges = {}
        ws = sheet.worksheets[i]

        ws.num_rows.times do |col|
          next if col == 0
          name1 = ws[1, col + 1]
          name1 = name1.split(":")[0].strip
          @people << name1 if i == 0
          (col+1...ws.num_rows).each do |row|
            name2 = ws[1, row + 1]
            name2 = name2.split(":")[0].strip
            pair = [name1, name2].sort
            data = ws[row + 1, col + 1]
            next if data.strip == ""
            @edges[pair] = data
          end
        end

        if i == 0
          @people.map! do |person|
            name, tier = person.split(":").map(&:strip)
            if name == "Han Solo"
              person = @matrix.han_solo
            else
              person = Person.new(name: name, tier: tier.to_i)
              @matrix.add_person(person)
            end
            person
          end
        end

        @edges.each do |pair, data|
          p1, p2 = pair
          p1 = find_person(p1)
          p2 = find_person(p2)
          edit_edge(p1, p2, data, i)
        end
      end
      progressbar.progress += 20


      @matrix
    end

    def save
      puts "Saving Matrix to Google Sheets..."
      progressbar = ProgressBar.create(total: 100)

      session = GoogleDrive.saved_session(CONFIG_FILE)
      sheet = session.spreadsheet_by_title("Pairity")
      @people = @matrix.all_people.sort

      progressbar.progress += 20
      (0..2).each do |i|
        ws = sheet.worksheets[i]

        @people.each_with_index do |person, index|
          ws[1, index + 2] = "#{person.name} : #{person.tier}"
          ws[index + 2, 1] = "#{person.name} : #{person.tier}"
        end

      progressbar.progress += 20
        @people.combination(2) do |pair|
          p1, p2 = pair
          index1 = @people.index(p1)
          index2 = @people.index(p2)
          edge = @matrix[p1,p2]
          case i
          when 0
            data = edge.weight
          when 1
            data = edge.days
          when 2
            data = edge.resistance
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

        (max..ws.num_rows).each do |i|
          (1..ws.num_rows).each do |j|
            ws[i, j] = ""
            ws[j, i] = ""
          end
        end

        ws.save
      end
      progressbar.progress += 20

    end

    def edit_edge(p1, p2, data, i)
      case i
      when 0
        @matrix[p1, p2].weight = data.to_i
      when 1
        @matrix[p1, p2].days = data.to_i
      when 2
        @matrix[p1, p2].resistance = data.to_i
      end
    end

    def find_person(name)

      person = @people.find { |person| person.name == name }

    end
  end
end
